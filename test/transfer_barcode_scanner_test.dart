// Product barcodes: what the app makes of real Open Food Facts records, how
// the lookup tells "no such product" from "no answer", and the scanner
// screen with the camera and the network replaced by stand-ins.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/services/barcode_scanner_service.dart';
import 'package:recipespellbook/utils/responsive_utils.dart';

const _cheerios = '016000275287';
const _nutella = '3017620422003';

/// Records as Open Food Facts returns them, cut down to the fields the app
/// reads. Each one is a real product whose record is filled in differently.
final _records = <String, Map<String, dynamic>>{
  // The brand is the name.
  _cheerios: {
    'code': '0016000275287',
    'product_name': 'Cheerios',
    'product_name_en': 'My Bff',
    'brands': 'Cheerios',
    'categories': 'en:Breakfast cereals',
    'serving_size': '39g',
    'nutriscore_grade': 'c',
    'completeness': 0.75,
    'last_modified_t': 1719000000,
    'nutriments': {'energy-kcal_100g': 359, 'proteins_100g': 12.8, 'sodium_100g': 0.487},
  },
  // Two brands, the first of them the name.
  _nutella: {
    'code': _nutella,
    'product_name': 'Nutella',
    'product_name_en': 'Nutella',
    'brands': 'Nutella, Ferrero',
    'categories': 'en:Confectionary based spreads, en:Petit-déjeuners, Nutella',
    'nutriscore_grade': 'e',
    'completeness': 0.9,
  },
  // No brand at all.
  '20005733': {
    'code': '20005733',
    'product_name': 'Cerneaux de Noix',
    'brands': '',
    'categories': 'Cerneaux de noix',
    'serving_size': '30 gram',
  },
  // The name is only filled in for some languages.
  '6111242100985': {
    'code': '6111242100985',
    'product_name': '',
    'product_name_en': 'Fromage frais nature',
    'product_name_fr': 'بيرلي جودة اخضر',
    'brands': 'Jaouda',
    'categories': 'لبن, fr:Fromages blancs natures',
  },
  // Someone scanned it once and filled in nothing.
  '0083078113131': {
    'code': '0083078113131',
    'product_name': '',
    'product_name_en': '',
    'brands': '',
    'categories': '',
    'nutriscore_grade': 'unknown',
    'completeness': 0.1625,
  },
  // Not even the fields are there.
  '0732913449866': {'code': '0732913449866', 'nutriscore_grade': 'unknown', 'completeness': 0.1},
  // An ordinary, complete record.
  '0028400090858': {
    'code': '0028400090858',
    'product_name': 'Classic Potato Chips',
    'brands': "Lay's",
    'categories': 'Cheeses, Potato crisps',
    'serving_size': '1 portion (28.3 g)',
  },
};

ProductInfo _product(String barcode) => ProductInfo.fromOpenFoodFacts(_records[barcode]!);

/// The camera plugin. [see] puts a barcode in front of it.
class _Camera extends MobileScannerPlatform {
  final _barcodes = StreamController<BarcodeCapture?>.broadcast();

  void see(String value) => _barcodes.add(BarcodeCapture(barcodes: [Barcode(rawValue: value)]));

  @override
  Stream<BarcodeCapture?> get barcodesStream => _barcodes.stream;
  @override
  Stream<TorchState> get torchStateStream => const Stream.empty();
  @override
  Stream<double> get zoomScaleStateStream => const Stream.empty();
  @override
  Widget buildCameraView() => const ColoredBox(color: Colors.black);
  @override
  Future<MobileScannerViewAttributes> start(StartOptions startOptions) async => const MobileScannerViewAttributes(
        cameraDirection: CameraFacing.back,
        currentTorchMode: TorchState.off,
        size: Size(1080, 1920),
      );
  @override
  Future<void> stop() async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> toggleTorch() async {}
  @override
  Future<void> updateScanWindow(Rect? window) async {}
  @override
  Future<void> dispose() async {}
}

/// Open Food Facts and the fallback database, answering from [_records].
class _Databases {
  /// What each database does with the next requests, when not the usual:
  /// Open Food Facts answering from its records, the fallback knowing nothing.
  http.Response Function()? openFoodFacts;
  http.Response Function()? fallback;

  int lookups = 0;
  final requests = <http.Request>[];

  http.Client get client => MockClient((request) async {
        requests.add(request);
        if (request.url.host != 'world.openfoodfacts.org') {
          return fallback?.call() ?? json({'code': 'OK', 'total': 0, 'items': []});
        }
        lookups++;
        final answer = openFoodFacts;
        if (answer != null) return answer();
        final barcode = request.url.pathSegments.last.replaceAll('.json', '');
        final record = _records[barcode];
        return record == null
            ? json({'code': barcode, 'status': 0, 'status_verbose': 'product not found'}, 404)
            : json({'code': barcode, 'status': 1, 'product': record});
      });

  static http.Response json(Object body, [int status = 200]) => http.Response.bytes(
        utf8.encode(jsonEncode(body)),
        status,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );

  Future<ProductLookup> lookUp(String barcode) =>
      http.runWithClient(() => BarcodeScannerService.lookupProduct(barcode), () => client);
}

/// The app around the scanner: a root navigator and inside it the one the
/// tabs live on, the way lib/router/router.dart sets them up.
class _App {
  _App() {
    router = GoRouter(
      navigatorKey: _root,
      initialLocation: '/shopping',
      routes: [
        ShellRoute(
          navigatorKey: _tabs,
          builder: (context, state, child) => Scaffold(
            body: child,
            bottomNavigationBar: const SizedBox(height: 56, child: Center(child: Text('tab bar'))),
          ),
          routes: [
            GoRoute(
              path: '/shopping',
              pageBuilder: (context, state) => NoTransitionPage(
                child: Builder(
                  builder: (context) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('shopping list'),
                      TextButton(onPressed: () => _scanFromTab(context), child: const Text('scan from the tab')),
                      TextButton(onPressed: () => _openSheet(context), child: const Text('open the add sheet')),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  final _root = GlobalKey<NavigatorState>();
  final _tabs = GlobalKey<NavigatorState>();
  late final GoRouter router;

  /// What the scanner handed back, once it has closed.
  Map<String, dynamic>? result;
  bool scannerClosed = false;

  String get location => router.routerDelegate.currentConfiguration.uri.toString();

  /// The Shopping tab's own call.
  Future<void> _scanFromTab(BuildContext context) async {
    result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(fullscreenDialog: true, builder: (_) => const BarcodeScannerScreen()),
    );
    scannerClosed = true;
  }

  /// The plus button: a sheet on the root navigator that opens the scanner.
  Future<void> _openSheet(BuildContext context) => Responsive.showAdaptiveSheet(
        context,
        builder: (sheetContext) => SizedBox(
          height: 200,
          child: Center(
            child: TextButton(
              onPressed: () async {
                result = await Navigator.of(sheetContext).push<Map<String, dynamic>>(
                  MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
                );
                scannerClosed = true;
              },
              child: const Text('scan from the sheet'),
            ),
          ),
        ),
      );

  Widget get widget => MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      );
}

const _phone = Size(390, 844);
const _tabletUpright = Size(820, 1180);
const _tabletSideways = Size(1180, 820);

/// Runs [body] with the scanner open on a device of [size].
Future<void> _scanning(
  WidgetTester tester,
  Future<void> Function(_App app, _Camera camera, _Databases databases) body, {
  Size size = _phone,
  bool fromSheet = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final realCamera = MobileScannerPlatform.instance;
  addTearDown(() => MobileScannerPlatform.instance = realCamera);
  final camera = _Camera();
  MobileScannerPlatform.instance = camera;
  final databases = _Databases();
  final app = _App();

  await http.runWithClient(() async {
    await tester.pumpWidget(app.widget);
    if (fromSheet) {
      await tester.tap(find.text('open the add sheet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('scan from the sheet'));
    } else {
      await tester.tap(find.text('scan from the tab'));
    }
    await tester.pumpAndSettle();
    expect(find.byType(BarcodeScannerScreen), findsOneWidget);
    await body(app, camera, databases);
  }, () => databases.client);
}

/// Shows [barcode] to the camera and waits for the lookup and what it opens.
Future<void> _scan(WidgetTester tester, _Camera camera, String barcode) async {
  camera.see(barcode);
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.pumpAndSettle();
}

/// The product sheet, as a phone shows it.
final _sheet = find.byType(DraggableScrollableSheet);

/// Taps a button of the product sheet. They sit below the fold.
Future<void> _tapInSheet(WidgetTester tester, String label) async {
  await tester.dragUntilVisible(find.text(label), find.byType(ListView).last, const Offset(0, -200));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // The lookup tells Open Food Facts which version of the app is asking.
    PackageInfo.setMockInitialValues(
      appName: 'Recipe Spellbook',
      packageName: 'app.recipespellbook',
      version: '1.7.0',
      buildNumber: '170',
      buildSignature: '',
    );
  });

  group('what a product is called', () {
    test('a brand that is already in the name is not said twice', () {
      expect(_product(_cheerios).displayName, 'Cheerios');
      expect(_product(_nutella).displayName, 'Nutella');
      expect(_product(_nutella).brand, 'Nutella');
    });

    test('a brand that is not in the name goes in front of it', () {
      expect(_product('0028400090858').displayName, "Lay's Classic Potato Chips");
    });

    test('an empty brand leaves the name as it is', () {
      final walnuts = _product('20005733');
      expect(walnuts.brand, isNull);
      expect(walnuts.displayName, 'Cerneaux de Noix');
    });

    test('a name that is only filled in for another language is used', () {
      final cheese = _product('6111242100985');
      expect(cheese.name, 'Fromage frais nature');
      expect(cheese.displayName, 'Jaouda Fromage frais nature');
    });

    test('of several languages the name is taken in the reader\'s, then in English, then in any', () {
      String? name(Map<String, dynamic> record, String language) =>
          ProductInfo.fromOpenFoodFacts(record, languageCode: language).name;
      const yogurt = {
        'product_name': ' ',
        'product_name_fr': 'Yaourt nature',
        'product_name_fr_debug_tags': ['48h'],
        'product_name_de': 'Naturjoghurt',
        'product_name_en': 'Plain yogurt',
        'generic_name': 'Fermented milk',
      };
      expect(name(yogurt, 'de'), 'Naturjoghurt');
      expect(name(yogurt, 'it'), 'Plain yogurt');
      expect(name({'product_name_fr_imported': 'Importé', 'product_name_fr': 'Yaourt nature'}, 'it'), 'Yaourt nature');
      // With no name anywhere, what the product is stands in for it.
      expect(name({'product_name': '', 'generic_name_en': 'Hazelnut spread', 'generic_name_de': 'Nusscreme'}, 'de'),
          'Nusscreme');
      // The record's own name comes before all of them.
      expect(name({...yogurt, 'product_name': 'Bio Joghurt'}, 'en'), 'Bio Joghurt');
    });

    test('a record with nothing in it has no name and no brand, not empty ones', () {
      for (final barcode in ['0083078113131', '0732913449866']) {
        final product = _product(barcode);
        expect(product.name, isNull, reason: barcode);
        expect(product.brand, isNull, reason: barcode);
        expect(product.category, isNull, reason: barcode);
        expect(product.displayName, 'Unknown Product', reason: barcode);
      }
    });

    test('the category is shown without its language code', () {
      expect(_product(_cheerios).category, 'Breakfast cereals');
      expect(_product(_nutella).category, 'Confectionary based spreads');
      expect(_product('0028400090858').category, 'Cheeses');
      expect(_product('6111242100985').category, 'لبن');
    });

    test('what is saved as a recipe carries the same name', () {
      final recipe = _product(_cheerios).toRecipeData();
      expect(recipe['title'], 'Cheerios');
      expect(recipe['description'], 'Scanned product from Cheerios');
      expect(recipe['category'], 'Breakfast cereals');
      expect(_product('0083078113131').toRecipeData()['description'], 'Scanned product');
    });

    test('the fallback database gets the same treatment', () {
      final spread = ProductInfo.fromUpcDatabase({
        'upc': '009800895007',
        'title': 'Nutella Hazelnut Spread 13 oz',
        'brand': 'Nutella',
        'category': '',
      });
      expect(spread.displayName, 'Nutella Hazelnut Spread 13 oz');
      expect(spread.category, isNull);
      final unnamed = ProductInfo.fromUpcDatabase({'upc': '009800895007', 'title': '', 'brand': ''});
      expect(unnamed.displayName, 'Unknown Product');
    });
  });

  group('looking a barcode up', () {
    test('a product the database has is found, and the request says who is asking', () async {
      final databases = _Databases();

      final found = await databases.lookUp(_nutella);

      expect(found, isA<ProductFound>());
      expect((found as ProductFound).product.displayName, 'Nutella');
      final request = databases.requests.single;
      expect(request.url.path, '/api/v0/product/$_nutella.json');
      expect(request.headers['User-Agent'], 'RecipeSpellbook/1.7.0 (support@recipespellbook.app)');
    });

    test('a barcode no database knows is not found', () async {
      final databases = _Databases();

      expect(await databases.lookUp('0000000000017'), isA<ProductNotFound>());
      expect(databases.requests.map((r) => r.url.host), ['world.openfoodfacts.org', 'api.upcitemdb.com']);

      // Some unknown barcodes are answered with 200 instead of 404.
      databases.openFoodFacts = () => _Databases.json({'code': '0000000000017', 'status': 0});
      expect(await databases.lookUp('0000000000017'), isA<ProductNotFound>());
    });

    test('not found stays not found when only the fallback database turns the request away', () async {
      final databases = _Databases()..fallback = () => http.Response('{"code":"TOO_FAST"}', 429);
      expect(await databases.lookUp('0000000000017'), isA<ProductNotFound>());

      databases.fallback = () => throw http.ClientException('Connection reset by peer');
      expect(await databases.lookUp('0000000000017'), isA<ProductNotFound>());
    });

    test('no answer is a failed lookup, not a product nobody knows', () async {
      final noAnswers = <String, http.Response Function()>{
        'no connection': () => throw http.ClientException("Failed host lookup: 'world.openfoodfacts.org'"),
        'a timeout': () => throw TimeoutException('Future not completed'),
        'a server error': () => http.Response('<html>503 Service Unavailable</html>', 503),
        'too many requests': () => http.Response('{"error":"rate limited"}', 429),
        'the sign-in page of a Wi-Fi': () =>
            http.Response('<html><body>Sign in to Hotel Wi-Fi</body></html>', 200, headers: {'content-type': 'text/html'}),
        'a page that is not from the database': () => http.Response('<html>404 Not Found</html>', 404),
        'JSON that is not a record': () => _Databases.json([1, 2, 3]),
        'the error of something in between': () => _Databases.json({'error': 'Not Found', 'path': '/api/v0'}, 404),
      };
      for (final MapEntry(key: what, value: answer) in noAnswers.entries) {
        final databases = _Databases()
          ..openFoodFacts = answer
          ..fallback = () => http.Response('{"code":"TOO_FAST"}', 429);
        expect(await databases.lookUp(_nutella), isA<ProductLookupFailed>(), reason: what);
      }
    });

    test('with no connection the fallback database is not kept waiting for as well', () async {
      for (final Object error in [http.ClientException('Failed host lookup'), TimeoutException('Future not completed')]) {
        final databases = _Databases()..openFoodFacts = () => throw error;

        expect(await databases.lookUp(_nutella), isA<ProductLookupFailed>());
        expect(databases.requests.map((r) => r.url.host), ['world.openfoodfacts.org']);
      }
    });

    test('the fallback database can find what Open Food Facts gave no answer for', () async {
      final databases = _Databases()
        ..openFoodFacts = (() => http.Response('', 503))
        ..fallback = () => _Databases.json({
              'code': 'OK',
              'items': [
                {'upc': '009800895007', 'title': 'Nutella Hazelnut Spread 13 oz', 'brand': 'Nutella'},
              ],
            });

      final found = await databases.lookUp('009800895007');

      expect(found, isA<ProductFound>());
      expect((found as ProductFound).product.displayName, 'Nutella Hazelnut Spread 13 oz');
    });

    test('a record with fields of the wrong kind still gives a product', () async {
      final databases = _Databases()
        ..openFoodFacts = () => _Databases.json({
              'status': 1,
              'product': {
                'code': 4008400402222,
                'product_name': 'Nutella',
                'brands': ['Ferrero'],
                'categories': 7,
                'serving_size': 15,
                'nova_group': '4',
                'nutriscore_grade': null,
                'additives_tags': 'en:e322',
                'last_modified_t': '1719000000',
                'completeness': '0.5',
                'nutriments': {'energy-kcal_100g': '539', 'sodium_100g': '0.04', 'fat_100g': 'n/a'},
              },
            });

      final found = await databases.lookUp('4008400402222');

      expect(found, isA<ProductFound>());
      final product = (found as ProductFound).product;
      expect(product.displayName, 'Nutella');
      expect((product.brand, product.category, product.servingSize, product.barcode), (null, null, null, ''));
      expect(product.novaGroup, 4);
      expect(product.additivesTags, isEmpty);
      expect(product.lastModified, DateTime.fromMillisecondsSinceEpoch(1719000000000));
      expect(product.nutrition, containsPair('calories', 539));
      expect(product.nutrition, containsPair('sodium', 40));
      expect(product.nutrition, containsPair('fat', null));
      expect(product.toRecipeData()['title'], 'Nutella');
    });
  });

  group('the product sheet', () {
    for (final (size, device) in [(_phone, 'a phone'), (_tabletUpright, 'an upright tablet'), (_tabletSideways, 'a tablet on its side')]) {
      for (final (label, action) in [
        ('Add to Shopping List', 'addToShopping'),
        ('Save as Recipe', 'saveAsRecipe'),
        ('Find Recipes with This', 'searchRecipes'),
      ]) {
        testWidgets('$label on $device hands the product to the Shopping tab', (tester) async {
          await _scanning(tester, size: size, (app, camera, databases) async {
            await _scan(tester, camera, _cheerios);
            await _tapInSheet(tester, label);

            expect(tester.takeException(), isNull);
            expect(app.result?['action'], action);
            expect((app.result?['product'] as ProductInfo?)?.barcode, '0016000275287');
            // The tab is still there, with nothing left on top of it.
            expect(app.location, '/shopping');
            expect(find.text('shopping list'), findsOneWidget);
            expect(find.text('tab bar'), findsOneWidget);
            expect(find.byType(BarcodeScannerScreen), findsNothing);
            expect(find.text(label), findsNothing);
          });
        });
      }
    }

    testWidgets('opened from a sheet, it closes itself and the scanner but not that sheet', (tester) async {
      await _scanning(tester, fromSheet: true, (app, camera, databases) async {
        await _scan(tester, camera, _cheerios);
        await _tapInSheet(tester, 'Add to Shopping List');

        expect(tester.takeException(), isNull);
        expect(app.result?['action'], 'addToShopping');
        expect(app.result?['product'], isA<ProductInfo>());
        expect(find.byType(BarcodeScannerScreen), findsNothing);
        expect(find.text('scan from the sheet'), findsOneWidget);
      });
    });

    testWidgets('a second barcode in view does not open a second sheet', (tester) async {
      await _scanning(tester, (app, camera, databases) async {
        await _scan(tester, camera, _cheerios);
        await _scan(tester, camera, _nutella);

        expect(databases.lookups, 1);
        expect(_sheet, findsOneWidget);

        await _tapInSheet(tester, 'Add to Shopping List');
        expect((app.result?['product'] as ProductInfo?)?.name, 'Cheerios');
      });
    });

    testWidgets('a barcode seen while the scanner is closing opens nothing', (tester) async {
      await _scanning(tester, (app, camera, databases) async {
        await _scan(tester, camera, _cheerios);
        await tester.dragUntilVisible(
            find.text('Add to Shopping List'), find.byType(ListView).last, const Offset(0, -200));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add to Shopping List'));
        // The sheet and the scanner are still sliding away.
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.byType(BarcodeScannerScreen), findsOneWidget);
        await _scan(tester, camera, _nutella);

        expect(databases.lookups, 1);
        expect(_sheet, findsNothing);
        expect(find.byType(BarcodeScannerScreen), findsNothing);
        expect((app.result?['product'] as ProductInfo?)?.name, 'Cheerios');
      });
    });

    testWidgets('Scan Another keeps the scanner open for the next product, the same one included', (tester) async {
      await _scanning(tester, (app, camera, databases) async {
        await _scan(tester, camera, _cheerios);
        await _tapInSheet(tester, 'Scan Another');

        expect(app.scannerClosed, isFalse);
        expect(find.byType(BarcodeScannerScreen), findsOneWidget);
        expect(_sheet, findsNothing);

        await _scan(tester, camera, _cheerios);
        expect(databases.lookups, 2);
        expect(_sheet, findsOneWidget);
      });
    });

    testWidgets('swiped away, it leaves the scanner open and the product can be scanned again', (tester) async {
      await _scanning(tester, (app, camera, databases) async {
        await _scan(tester, camera, _cheerios);
        // The back gesture, a swipe down and a tap beside the sheet all end here.
        Navigator.of(tester.element(find.text('Cheerios').last)).pop();
        await tester.pumpAndSettle();

        expect(app.scannerClosed, isFalse);
        expect(find.byType(BarcodeScannerScreen), findsOneWidget);
        expect(_sheet, findsNothing);

        await _scan(tester, camera, _cheerios);
        expect(databases.lookups, 2);
        expect(_sheet, findsOneWidget);
      });
    });

    testWidgets('a record with nothing filled in is shown as an unknown product, not as a blank', (tester) async {
      await _scanning(tester, (app, camera, databases) async {
        await _scan(tester, camera, '0083078113131');

        expect(find.descendant(of: _sheet, matching: find.text('Unknown Product')), findsOneWidget);
        expect(find.descendant(of: _sheet, matching: find.text('')), findsNothing);

        await _tapInSheet(tester, 'Add to Shopping List');
        expect((app.result?['product'] as ProductInfo?)?.displayName, 'Unknown Product');
      });
    });

    testWidgets('a web address in a code closes the scanner with the address', (tester) async {
      await _scanning(tester, (app, camera, databases) async {
        await _scan(tester, camera, 'https://example.com/recipes/apple-pie');

        expect(app.result, {'action': 'importFromUrl', 'url': 'https://example.com/recipes/apple-pie'});
        expect(find.byType(BarcodeScannerScreen), findsNothing);
        expect(databases.lookups, 0);
        expect(app.location, '/shopping');
      });
    });
  });

  group('when the lookup has no product to show', () {
    testWidgets('a lookup nobody answered offers another try, and the second try finds the product', (tester) async {
      await _scanning(tester, (app, camera, databases) async {
        databases.openFoodFacts = () => throw http.ClientException('Failed host lookup');
        await _scan(tester, camera, _cheerios);

        expect(find.text('Could Not Look Up Product'), findsOneWidget);
        expect(find.text('Product Not Found'), findsNothing);
        // Another barcode in view does not pile a second dialog on top.
        await _scan(tester, camera, _nutella);
        expect(find.text('Could Not Look Up Product'), findsOneWidget);
        expect(databases.lookups, 1);

        databases.openFoodFacts = null;
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        expect(databases.lookups, 2);
        expect(find.text('Could Not Look Up Product'), findsNothing);
        expect(_sheet, findsOneWidget);
        await _tapInSheet(tester, 'Add to Shopping List');
        expect((app.result?['product'] as ProductInfo?)?.name, 'Cheerios');
      });
    });

    testWidgets('a second failure asks again instead of giving up', (tester) async {
      await _scanning(tester, (app, camera, databases) async {
        databases.openFoodFacts = () => http.Response('', 503);
        await _scan(tester, camera, _cheerios);
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        expect(databases.lookups, 2);
        expect(find.text('Could Not Look Up Product'), findsOneWidget);
        expect(app.scannerClosed, isFalse);
      });
    });

    testWidgets('without an answer the name can be typed in instead', (tester) async {
      await _scanning(tester, (app, camera, databases) async {
        databases.openFoodFacts = () => throw TimeoutException('Future not completed');
        await _scan(tester, camera, _cheerios);
        await tester.tap(find.text('Enter Manually'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), '  Oat Milk ');
        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(app.result, {'action': 'addToShopping', 'name': 'Oat Milk'});
        expect(find.byType(BarcodeScannerScreen), findsNothing);
        expect(find.text('shopping list'), findsOneWidget);
      });
    });

    testWidgets('a product nobody knows can be typed in', (tester) async {
      await _scanning(tester, (app, camera, databases) async {
        await _scan(tester, camera, '0000000000017');

        expect(find.text('Product Not Found'), findsOneWidget);
        expect(find.text('Could Not Look Up Product'), findsNothing);

        await tester.tap(find.text('Enter Manually'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Oat Milk');
        await tester.tap(find.text('Add'));
        await tester.pumpAndSettle();

        expect(app.result, {'action': 'addToShopping', 'name': 'Oat Milk'});
        expect(app.location, '/shopping');
      });
    });

    testWidgets('typing nothing, or cancelling, goes back to scanning', (tester) async {
      await _scanning(tester, (app, camera, databases) async {
        for (final button in ['Add', 'Cancel']) {
          await _scan(tester, camera, '0000000000017');
          await tester.tap(find.text('Enter Manually'));
          await tester.pumpAndSettle();
          await tester.tap(find.text(button));
          await tester.pumpAndSettle();

          expect(app.scannerClosed, isFalse, reason: button);
          expect(find.byType(AlertDialog), findsNothing, reason: button);
        }
        // Both times the same barcode was looked up afresh.
        expect(databases.lookups, 2);
      });
    });

    for (final (title, answer) in <(String, http.Response Function()?)>[
      ('Product Not Found', null),
      ('Could Not Look Up Product', () => http.Response('', 503)),
    ]) {
      testWidgets('"$title" closed by Scan Again or a tap beside it lets the barcode be scanned again', (tester) async {
        await _scanning(tester, (app, camera, databases) async {
          databases.openFoodFacts = answer;
          await _scan(tester, camera, '0000000000017');
          expect(find.text(title), findsOneWidget);
          await tester.tap(find.text('Scan Again'));
          await tester.pumpAndSettle();
          expect(find.text(title), findsNothing);

          await _scan(tester, camera, '0000000000017');
          expect(find.text(title), findsOneWidget);
          await tester.tapAt(const Offset(8, 8));
          await tester.pumpAndSettle();
          expect(find.text(title), findsNothing);

          await _scan(tester, camera, '0000000000017');
          expect(find.text(title), findsOneWidget);
          expect(databases.lookups, 3);
          expect(app.scannerClosed, isFalse);
        });
      });
    }
  });
}
