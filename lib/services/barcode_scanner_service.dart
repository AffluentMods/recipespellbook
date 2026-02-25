import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import '../../../l10n/app_localizations.dart';

/// Service for scanning barcodes and looking up product information
class BarcodeScannerService {
  /// Look up product info from Open Food Facts API
  static Future<ProductInfo?> lookupProduct(String barcode) async {
    try {
      // Use Open Food Facts API (free, no API key required)
      final url = 'https://world.openfoodfacts.org/api/v0/product/$barcode.json';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          return ProductInfo.fromOpenFoodFacts(data['product']);
        }
      }

      // Try UPC Database as fallback
      return await _lookupUpcDatabase(barcode);
    } catch (e) {
      debugPrint('Product lookup failed: $e');
      return null;
    }
  }

  static Future<ProductInfo?> _lookupUpcDatabase(String barcode) async {
    try {
      // UPC Database API (limited free tier)
      final url = 'https://api.upcitemdb.com/prod/trial/lookup?upc=$barcode';
      final response = await http.get(Uri.parse(url));

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

  ProductInfo({
    required this.barcode,
    this.name,
    this.brand,
    this.category,
    this.imageUrl,
    this.nutrition,
    this.ingredients,
    this.servingSize,
  });

  factory ProductInfo.fromOpenFoodFacts(Map<String, dynamic> data) {
    // Parse ingredients text into list
    List<String>? ingredientsList;
    if (data['ingredients_text'] != null) {
      ingredientsList = (data['ingredients_text'] as String)
          .split(RegExp(r',\s*'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    // Parse nutrition
    Map<String, dynamic>? nutrition;
    if (data['nutriments'] != null) {
      final n = data['nutriments'];
      nutrition = {
        'calories': n['energy-kcal_100g'],
        'protein': n['proteins_100g'],
        'carbs': n['carbohydrates_100g'],
        'fat': n['fat_100g'],
        'fiber': n['fiber_100g'],
        'sugar': n['sugars_100g'],
        'sodium': n['sodium_100g'] != null ? (n['sodium_100g'] * 1000) : null, // Convert to mg
        'saturatedFat': n['saturated-fat_100g'],
      };
    }

    return ProductInfo(
      barcode: data['code'] ?? '',
      name: data['product_name'] ?? data['product_name_en'],
      brand: data['brands'],
      category: data['categories']?.split(',')?.first?.trim(),
      imageUrl: data['image_url'] ?? data['image_front_url'],
      nutrition: nutrition,
      ingredients: ingredientsList,
      servingSize: data['serving_size'],
    );
  }

  factory ProductInfo.fromUpcDatabase(Map<String, dynamic> data) {
    return ProductInfo(
      barcode: data['upc'] ?? data['ean'] ?? '',
      name: data['title'],
      brand: data['brand'],
      category: data['category'],
      imageUrl: (data['images'] as List?)?.isNotEmpty == true ? data['images'][0] : null,
    );
  }

  /// Get display name (brand + name)
  String get displayName {
    if (brand != null && name != null) {
      return '$brand $name';
    }
    return name ?? brand ?? 'Unknown Product';
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
class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  MobileScannerController? _controller;
  bool _isProcessing = false;
  String? _lastScannedBarcode;
  ProductInfo? _scannedProduct;
  bool _torchEnabled = false;

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
    if (_isProcessing) return;
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
        Navigator.pop(context, {'action': 'importFromUrl', 'url': value});
      }
      return;
    }

    // Standard barcode → product lookup
    final product = await BarcodeScannerService.lookupProduct(value);

    if (mounted) {
      setState(() {
        _scannedProduct = product;
        _isProcessing = false;
      });

      if (product != null) {
        _showProductSheet(product);
      } else {
        _showNotFoundDialog(value);
      }
    }
  }

  void _showProductSheet(ProductInfo product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProductInfoSheet(
        product: product,
        onAddToShopping: () => _addToShopping(product),
        onSearchRecipes: () => _searchRecipes(product),
        onSaveAsRecipe: () => _saveAsRecipe(product),
        onScanAnother: () {
          Navigator.pop(ctx);
          setState(() {
            _lastScannedBarcode = null;
            _scannedProduct = null;
          });
        },
      ),
    );
  }

  void _showNotFoundDialog(String barcode) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
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
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _lastScannedBarcode = null);
            },
            child: Text(l10n.scanAgain),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showManualEntryDialog(barcode);
            },
            child: Text(l10n.enterManually),
          ),
        ],
      ),
    );
  }

  void _showManualEntryDialog(String barcode) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    showDialog(
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
            onPressed: () {
              Navigator.pop(ctx);
              if (controller.text.trim().isNotEmpty) {
                _addManualProductToShopping(controller.text.trim());
              }
              setState(() => _lastScannedBarcode = null);
            },
            child: Text(l10n.actionAdd),
          ),
        ],
      ),
    );
  }

  void _addToShopping(ProductInfo product) {
    // Add to shopping list
    Navigator.pop(context); // Close sheet
    Navigator.pop(context, {'action': 'addToShopping', 'product': product});
  }

  void _saveAsRecipe(ProductInfo product) {
    Navigator.pop(context); // Close sheet
    Navigator.pop(context, {'action': 'saveAsRecipe', 'product': product});
  }

  void _addManualProductToShopping(String name) {
    Navigator.pop(context, {'action': 'addToShopping', 'name': name});
  }

  void _searchRecipes(ProductInfo product) {
    Navigator.pop(context); // Close sheet
    Navigator.pop(context, {'action': 'searchRecipes', 'product': product});
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
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Actions
                    FilledButton.icon(
                      onPressed: onAddToShopping,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: Text(l10n.addToShoppingList),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: onSearchRecipes,
                      icon: const Icon(Icons.search),
                      label: Text(l10n.findRecipesWithThis),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: onSaveAsRecipe,
                      icon: const Icon(Icons.menu_book),
                      label: Text(l10n.saveAsRecipe),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 12),
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