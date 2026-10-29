import 'dart:convert';
import '../../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/platform_utils.dart';
import 'package:path/path.dart' as p;
import '../../data/nutrition_data.dart';
import '../../database/database.dart';
import '../../l10n/app_localizations.dart';
import '../../models/imported_recipe.dart';
import '../../services/imported_recipe_saver.dart';
import '../../services/recipe_file_importers/file_import_dispatcher.dart';
import '../../services/recipe_file_importers/import_support.dart';
import '../../providers/database_provider.dart';
import '../../services/ocr_service.dart';
import '../../services/recipe_import_engine.dart';
import '../screens/book_scan/book_scan_entry.dart';
import '../screens/import/ai_import_screen.dart';
import '../screens/import/import_guides_screen.dart';
import '../screens/import/import_preview_screen.dart';
import 'app_snackbar.dart';
import 'platform_brand.dart';
import '../../services/barcode_scanner_service.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/text_normalize.dart';
import 'sheet_chrome.dart';

/// Shows the MODERN add recipe dialog with 2 options
Future<void> showNewRecipeDialog(BuildContext context, String cookbookId) {
  return Responsive.showAdaptiveSheet(
    context,
    builder: (context) => _AddRecipeChooser(cookbookId: cookbookId),
  );
}

/// Also expose showImportDialog for direct access to import menu.
/// [autoScanBarcode] jumps straight into the barcode scanner on open — used by
/// the menu/drawer "Scan barcode" entry so it reuses the full import handling.
Future<void> showImportDialog(BuildContext context, String cookbookId, {bool autoScanBarcode = false}) {
  return Responsive.showAdaptiveSheet(
    context,
    builder: (context) => _ImportRecipeSheet(cookbookId: cookbookId, autoScanBarcode: autoScanBarcode),
  );
}

// ============ MODERN CHOOSER (2 options) ============

class _AddRecipeChooser extends StatelessWidget {
  final String cookbookId;
  const _AddRecipeChooser({required this.cookbookId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: SheetPresentation.surfaceRadius(context),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SheetHandle(top: 0),
              const SizedBox(height: 24),
              Text(l10n.recipeAdd, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(l10n.importChooseMethod, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _OptionCard(
                      icon: Icons.edit_note_rounded,
                      title: l10n.importCreate,
                      subtitle: l10n.importCreateSubtitle,
                      color: theme.colorScheme.primary,
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/cookbook/$cookbookId/new-recipe');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _OptionCard(
                      icon: Icons.download_rounded,
                      title: l10n.importTitle,
                      subtitle: l10n.importSubtitle,
                      color: theme.colorScheme.tertiary,
                      onTap: () {
                        Navigator.pop(context);
                        showImportDialog(context, cookbookId);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _OptionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 16),
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ IMPORT SHEET ============

/// The recipes of the app's own export, when that is what the [bytes] of a
/// JSON file hold, or null when they hold anything else. Runs in the
/// background: a backup with its photos in it is a long text to take apart.
List<ImportedRecipe>? _ownExportIn(Uint8List bytes) {
  // Read the way the file importers read text: UTF-8 or, behind its byte
  // order mark, UTF-16. The mark is not part of the JSON.
  final text = ImportSupport.decodeText(bytes);
  // The JSON of another app is left to its importer and not decoded twice.
  if (!text.contains('"version"') || !text.contains('"cookbook')) return null;
  try {
    final json = jsonDecode(text);
    return OwnExport.matches(json) ? OwnExport.recipes(json as Map) : null;
  } catch (_) {
    return null;
  }
}

/// The kinds of picked file that are read with the text recognition.
enum _FileKind { pdf, photo }

class _ImportRecipeSheet extends ConsumerStatefulWidget {
  final String cookbookId;
  final bool autoScanBarcode;
  const _ImportRecipeSheet({required this.cookbookId, this.autoScanBarcode = false});

  @override
  ConsumerState<_ImportRecipeSheet> createState() => _ImportRecipeSheetState();
}

class _ImportRecipeSheetState extends ConsumerState<_ImportRecipeSheet> {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  String? _loadingMessage;
  RecipePlatform? _detected; // live platform detected from the pasted link

  @override
  void initState() {
    super.initState();
    _urlController.addListener(_onUrlChanged);
    // Menu/drawer "Scan barcode" entry: jump straight into the scanner.
    if (widget.autoScanBarcode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _importFromBarcode();
      });
    }
  }

  void _onUrlChanged() {
    final next = detectPlatform(_urlController.text);
    if (next != _detected) setState(() => _detected = next);
  }

  Future<void> _pasteUrl() async {
    HapticFeedback.selectionClick();
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) {
      _showError('Nothing to paste, copy a recipe link first.');
      return;
    }
    _urlController.text = text;
    _urlController.selection = TextSelection.collapsed(offset: text.length);
  }

  @override
  void dispose() {
    _urlController.removeListener(_onUrlChanged);
    _urlController.dispose();
    super.dispose();
  }

  // The sheet can be closed while a scan or a download is still running, so
  // what comes back afterwards must not touch it any more.
  void _showLoading(String message) {
    if (!mounted) return;
    setState(() { _isLoading = true; _loadingMessage = message; });
  }

  void _hideLoading() {
    if (!mounted) return;
    setState(() { _isLoading = false; _loadingMessage = null; });
  }

  void _showError(String message) {
    if (!mounted) return;
    AppSnackbar.error(context, message);
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    AppSnackbar.success(context, message);
  }

  // ========== URL IMPORT ==========
  Future<void> _importFromUrl() async {
    final raw = _urlController.text.trim();
    if (raw.isEmpty) { _showError('Paste a recipe link first.'); return; }

    // This box is for links, but people paste recipe JSON or plain text into it.
    // Detect that and route it to the right parser instead of trying to fetch it
    // as a URL (which used to crash with "Invalid port").
    if (raw.startsWith('{') || raw.startsWith('[') || raw.startsWith('```')) {
      return _importPastedJson(raw);
    }

    // What gets pasted is often a share message with the link somewhere in
    // it ("Check out this recipe! https://..."). The link is what counts then.
    final link = _linkIn(raw);
    final finalUrl = _normalizeAndValidateUrl(link ?? raw);
    if (finalUrl == null) {
      // Not a valid link. If it's a decent chunk of text, treat it as a pasted
      // recipe; otherwise tell the user plainly.
      if (raw.length > 40 && raw.contains(' ')) {
        return _importPastedText(raw);
      }
      _showError('That doesn’t look like a recipe link. Paste a link starting with https://, or use “Paste text” below.');
      return;
    }

    final around = link == null ? '' : raw.replaceAll(_links, ' ').trim();
    if (around.isNotEmpty) return _importPastedText(around, link: finalUrl);
    return _importFromLink(finalUrl);
  }

  /// Fetches the recipe behind [url]. [otherwise] is what the text pasted
  /// around the link was read as: it is offered when the link gives nothing.
  Future<void> _importFromLink(String url, {List<ImportedRecipe> otherwise = const [], String? sourceText}) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    var failure = l10n.importNoRecipeAtLink;
    _showLoading(l10n.importProgress);
    try {
      final recipe = await RecipeImportEngine.parseFromUrl(url);
      if (hasRecipeContent(recipe)) {
        _hideLoading();
        _showImportPreview([recipe], sourceUrl: url);
        return;
      }
    } catch (e) {
      failure = _friendlyImportError(e, l10n);
    }
    _hideLoading();
    if (otherwise.any(hasRecipeContent)) {
      _showImportPreview(otherwise, sourceText: sourceText);
    } else {
      _showError(failure);
    }
  }

  // A link ends where something comes that no address holds: a space, a
  // quote of any kind, the punctuation of Chinese and Japanese text, the
  // full-width forms, guillemets and the long dashes.
  static final _links = RegExp(
    r'https?://[^\s<>"{}|\\^`\[\]\u2010-\u205E\u3000-\u303F\uFF00-\uFF65«»]+',
    caseSensitive: false,
  );

  /// The first http(s) link in [text], without the full stop, bracket or
  /// quote of the sentence around it. Null when there is none.
  static String? _linkIn(String text) {
    final found = _links.firstMatch(text)?.group(0);
    if (found == null) return null;
    // Brackets the link itself has open, as in ".../wiki/Roux_(sauce)". A
    // closing one beyond those belongs to the sentence.
    var open = '('.allMatches(found).length - ')'.allMatches(found).length;
    var end = found.length;
    while (end > 0) {
      final last = found[end - 1];
      if (last == ')' && open < 0) {
        open++;
      } else if (!_sentenceEnd.hasMatch(last) || _addressEnd.contains(last)) {
        break;
      }
      end--;
    }
    return found.substring(0, end);
  }

  /// Punctuation and symbols, of any script, that a sentence can put after a
  /// link. Of those, an address can end in the ones in [_addressEnd].
  static final _sentenceEnd = RegExp(r'[\p{P}\p{S}]', unicode: true);
  static const _addressEnd = '/=&#%+-_~)';

  /// Validate + normalize a user-entered URL. Returns null when it isn't a safe
  /// http(s) link — blocks other schemes (file:, javascript:, data:…) and
  /// local/private hosts so a malicious shared "link" can't point the app at
  /// the device's own network.
  String? _normalizeAndValidateUrl(String input) {
    var s = input.trim();
    // Several lines are a text, whatever the first of them looks like.
    if (s.isEmpty || s.contains('\n') || s.contains('\r')) return null;
    final lower = s.toLowerCase();
    if (!lower.startsWith('http://') && !lower.startsWith('https://')) {
      // A different explicit scheme is never a recipe link — reject it rather
      // than blindly prefixing https://.
      if (RegExp(r'^[a-zA-Z][a-zA-Z0-9+.\-]*:').hasMatch(s)) return null;
      s = 'https://$s';
    }
    final uri = Uri.tryParse(s);
    if (uri == null || !uri.hasAuthority || uri.host.isEmpty) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    if (!uri.host.contains('.')) return null; // needs a real domain
    // Uri takes a sentence for a host name and writes its spaces as %20. No
    // host has those, and a pasted sentence must not be fetched as a link.
    if (uri.host.contains('%')) return null;
    if (_isBlockedHost(uri.host)) return null;
    return uri.toString();
  }

  /// Basic SSRF guard: block localhost / private / link-local hosts.
  bool _isBlockedHost(String host) {
    final h = host.toLowerCase();
    if (h == 'localhost' || h.endsWith('.local') || h.endsWith('.internal')) return true;
    if (h == '::1' || h.startsWith('[')) return true; // IPv6 loopback / literal
    final m = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$').firstMatch(h);
    if (m != null) {
      final a = int.parse(m.group(1)!);
      final b = int.parse(m.group(2)!);
      if (a == 0 || a == 127 || a == 10) return true;         // this-host / loopback / private
      if (a == 192 && b == 168) return true;                  // private
      if (a == 169 && b == 254) return true;                  // link-local
      if (a == 172 && b >= 16 && b <= 31) return true;        // private
    }
    return false;
  }

  /// Parse recipe JSON pasted into the link box (e.g. AI-generated JSON).
  Future<void> _importPastedJson(String content) async {
    var body = content.trim();
    if (body.startsWith('```')) {
      body = body
          .replaceFirst(RegExp(r'^```[a-zA-Z]*\s*'), '')
          .replaceFirst(RegExp(r'```\s*$'), '')
          .trim();
    }
    const noRecipe = 'We couldn’t read a recipe from that JSON. For AI-generated recipes, use the “AI” option below.';
    _showLoading(AppLocalizations.of(context)!.parsingRecipe);
    try {
      // App's own export bundle?
      dynamic decoded;
      try {
        decoded = jsonDecode(body);
      } catch (_) {
        _hideLoading();
        // "[Budget Bytes] One Pot Chili https://..." only starts like JSON.
        // A share message is read for its link.
        final link = _linkIn(body);
        final url = link == null ? null : _normalizeAndValidateUrl(link);
        if (url != null) {
          final around = body.replaceAll(_links, ' ').trim();
          return around.isEmpty ? _importFromLink(url) : _importPastedText(around, link: url);
        }
        _showError('That looks like recipe data, but it isn’t valid JSON. Copy the whole thing and try again.');
        return;
      }
      if (OwnExport.matches(decoded)) {
        _hideLoading();
        _processOwnExportFormat(OwnExport.recipes(decoded as Map), nothingFound: noRecipe);
        return;
      }

      final recipes = RecipeImportEngine.parseFromFileBulk(body, 'pasted.json');
      _hideLoading();
      if (recipes.any(hasRecipeContent)) {
        _showImportPreview(recipes, sourceText: body);
        return;
      }
      _showError(noRecipe);
    } catch (e) {
      _hideLoading();
      _showError(noRecipe);
    }
  }

  /// Parse a big blob of pasted recipe text that isn't a link. [link] is the
  /// link that was pasted along with it, if there was one.
  Future<void> _importPastedText(String text, {String? link}) async {
    final l10n = AppLocalizations.of(context)!;
    _showLoading(l10n.parsingRecipe);
    try {
      final recipes = RecipeImportEngine.parseTextMulti(text);
      _hideLoading();
      // A share message says little besides its link, and the recipe is
      // behind the link. Only a text that is a whole recipe by itself, with
      // ingredients and steps, is taken for what it says.
      if (link != null && !recipes.any((r) => r.ingredients.isNotEmpty && r.instructions.isNotEmpty)) {
        return _importFromLink(link, otherwise: recipes, sourceText: text);
      }
      if (!recipes.any(hasRecipeContent)) {
        _showError('We couldn’t find a recipe in that text. For long recipes, use “Paste text” below.');
        return;
      }
      _showImportPreview(recipes, sourceText: text);
    } catch (e) {
      _hideLoading();
      _showError(_friendlyImportError(e, l10n));
    }
  }

  /// Turn a raw import failure into a plain-English message.
  String _friendlyImportError(Object e, AppLocalizations l10n) {
    final s = e.toString().toLowerCase();
    if (s.contains('socketexception') || s.contains('failed host lookup') ||
        s.contains('network') || s.contains('timeout') || s.contains('timed out') ||
        s.contains('connection')) {
      return 'Couldn’t reach that link. Check your connection and try again.';
    }
    if (s.contains('403') || s.contains('401') || s.contains('login') ||
        s.contains('private') || s.contains('sign in')) {
      return 'That page needs a login, so we can’t read it. Try a public link.';
    }
    if (s.contains('404') || s.contains('not found')) {
      return 'That link couldn’t be found. Double-check the URL.';
    }
    if (s.contains('no recipe') || s.contains('empty')) {
      return l10n.importNoRecipeAtLink;
    }
    return 'We couldn’t read a recipe from that link. Try a different link, or paste the recipe text below.';
  }

  // ========== BARCODE / QR IMPORT ==========
  Future<void> _importFromBarcode() async {

    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (result == null || !mounted) return;

    final action = result['action'] as String?;

    switch (action) {
      case 'importFromUrl':
      // QR code with a URL → run through recipe import engine
        final url = result['url'] as String;
        _urlController.text = url;
        _importFromUrl();
        break;

      case 'saveAsRecipe':
      // Barcode product → create a quick pantry recipe
        final l10n = AppLocalizations.of(context)!;
        final product = result['product'] as ProductInfo;
        // Taken from the product itself: whatever form its figures came in,
        // nothing here can fail on them.
        final nutrition = _productNutrition(product);
        final brand = _brandOf(product);
        final servingSize = product.servingSize?.trim();
        final recipe = ImportedRecipe(
          title: _productName(product) ?? l10n.unknownProduct,
          description: brand == null ? null : l10n.scanProductFrom(brand),
          servings: nutrition?.servings ?? (servingSize == null || servingSize.isEmpty ? null : servingSize),
          ingredients: List.of(product.ingredients ?? const <String>[]),
          instructions: [],
          imageUrl: product.imageUrl,
          nutritionJson: nutrition?.json,
        );
        // With no list of ingredients and no nutrition facts there is only
        // a name, and a name alone is not a recipe.
        if (!hasRecipeContent(recipe)) {
          _showError(l10n.scanProductNoRecipe);
          break;
        }
        _showImportPreview([recipe]);
        break;

      case 'addToShopping':
      // Add scanned product to default shopping list
        final product = result['product'] as ProductInfo?;
        final manualName = result['name'] as String?;
        final itemName = (product == null ? manualName : _productName(product))?.trim();

        if (itemName == null || itemName.isEmpty) {
          _showError(AppLocalizations.of(context)!.scanProductNoName);
        } else {
          try {
            final shoppingDao = ref.read(shoppingDaoProvider);
            final itemId = 'item_${DateTime.now().millisecondsSinceEpoch}';
            await shoppingDao.insertItem(ShoppingListItemsCompanion.insert(
              id: itemId,
              listId: 'list_default',
              name: itemName,
              sortOrder: const drift.Value(0),
            ));
            if (mounted) {
              _showSuccess('Added to shopping list: $itemName');
            }
          } catch (e) {
            if (mounted) {
              _showError('Failed to add to shopping list: $e');
            }
          }
        }
        break;

      case 'searchRecipes':
      // Navigate to search screen
        if (mounted) {
          Navigator.of(context).pop(); // Close import sheet
          context.push('/search');
        }
        break;
    }
  }

  /// What a scanned product is called: its name, with its brand in front
  /// unless the name already says it. The product database lists several
  /// brands for some products ("Nutella, Ferrero"), repeats the brand in the
  /// name of others and leaves either field empty for many. Null when it has
  /// neither.
  ///
  /// "Lays Classic" says the brand "Lay's", and "Nestle KitKat" says
  /// "Nestlé": accents and apostrophes do not count. A name that starts with
  /// the first word of the brand says it too ("Coca-Cola Original" of
  /// "COCA-COLA SERVICES SA/NV").
  static String? _productName(ProductInfo product) {
    final name = (product.name ?? '').trim();
    final brand = _brandOf(product);
    if (name.isEmpty) return brand;
    if (brand == null) return name;
    final plainName = _plain(name), plainBrand = _plain(brand);
    final firstWord = plainBrand.split(' ').first;
    if (plainName.contains(plainBrand) || (firstWord.isNotEmpty && plainName.split(' ').first == firstWord)) return name;
    return '$brand $name';
  }

  /// The first brand a product lists, or null when it lists none.
  static String? _brandOf(ProductInfo product) {
    final brand = (product.brand ?? '').split(',').first.trim();
    return brand.isEmpty ? null : brand;
  }

  /// [text] in lower case without accents and apostrophes, its words split
  /// at anything that is not a letter or a digit.
  static String _plain(String text) =>
      foldAccents(text).replaceAll(_apostrophes, '').replaceAll(_notWord, ' ').trim();
  static final _apostrophes = RegExp('[\'\u2019]');
  static final _notWord = RegExp(r'[^\p{L}\p{N}]+', unicode: true);

  /// The nutrition facts of a scanned product in the app's own format, and
  /// what the recipe then gives as its servings. Null when the product has
  /// none.
  ///
  /// The product database gives them for 100 g. When the pack says what a
  /// serving weighs ("2 tbsp (37 g)") they are worked out for that serving,
  /// otherwise 100 g is the serving.
  ///
  /// A recipe counts its servings, and the recipe screen takes the first
  /// number in that text for the count: it divides the nutrition by it and
  /// steps it up and down. So the product is one serving, with the size of
  /// it in brackets, "1 (15 g)". Left as "15 g" it would be read as fifteen
  /// servings, each with a fifteenth of the figures.
  static ({String json, String servings})? _productNutrition(ProductInfo product) {
    final per100g = product.nutrition;
    if (per100g == null) return null;
    final weight = _servingWeight(product.servingSize);
    final serving = weight == null ? '100 g' : product.servingSize!.trim();

    double? perServing(String key) {
      final value = per100g[key];
      final number = value is num ? value.toDouble() : (value is String ? double.tryParse(value.trim()) : null);
      if (number == null || !number.isFinite) return null;
      return (number * (weight ?? 100)).roundToDouble() / 100;
    }

    final facts = NutritionData(
      calories: perServing('calories'),
      protein: perServing('protein'),
      carbohydrates: perServing('carbs'),
      fat: perServing('fat'),
      fiber: perServing('fiber'),
      sugar: perServing('sugar'),
      sodium: perServing('sodium'),
      saturatedFat: perServing('saturatedFat'),
      servingSize: serving,
      calculatedServings: 1,
    );
    if (!facts.hasAnyData && facts.saturatedFat == null) return null;
    return (json: jsonEncode(facts.toJson()), servings: '1 ($serving)');
  }

  /// What one serving weighs in grams (or measures in millilitres), as far as
  /// the serving size printed on a pack says: "39g", "1 cup (240 ml)",
  /// "1 biscuit (12,5 g)", "2 Löffel (30 g)", "30 grams".
  ///
  /// The weight in brackets is the one that counts when there is one: the
  /// count in front of it is of spoons, biscuits or slices. A unit is a unit
  /// only when no letter follows it, so the G of "2 gâteaux" is not grams.
  static double? _servingWeight(String? servingSize) {
    final text = servingSize ?? '';
    // The serving size of a pack is a few words. Anything longer is not one.
    if (text.length > 100) return null;
    final bracketed = _bracketed.allMatches(text).map((m) => m.group(1)!);
    for (final part in [...bracketed, text]) {
      final found = _weight.firstMatch(part);
      if (found == null) continue;
      final digits = found.group(1)!;
      // "1,000 g" is a thousand grams, "12,5 g" twelve and a half.
      final amount = double.tryParse(
        RegExp(r'^\d{1,3},\d{3}$').hasMatch(digits) ? digits.replaceFirst(',', '') : digits.replaceFirst(',', '.'),
      );
      if (amount == null || amount <= 0) return null;
      final unit = found.group(2)!.toLowerCase();
      return amount *
          switch (unit) {
            'kg' || 'l' || 'л' => 1000,
            'dl' => 100,
            'cl' => 10,
            'mg' => 0.001,
            _ => 1,
          };
    }
    return null;
  }

  static final _bracketed = RegExp(r'\(([^()]*)\)');
  static final _weight = RegExp(
    r'(?<![\d.,])(\d{1,6}(?:[.,]\d{1,3})?)\s*(kg|mg|grammes?|grams?|gr|g|ml|мл|cl|dl|l|г|л)(?![\p{L}\p{N}])',
    caseSensitive: false,
    unicode: true,
  );

  // ========== SCANS (PDF + IMAGE) ==========

  /// The parser scores how much of the text it understood, the text
  /// recognition how well it could read the picture. Either being low is
  /// worth a warning in the preview, so the lower one is kept.
  static double _lowerConfidence(double? parsed, double read) => parsed != null && parsed < read ? parsed : read;

  // ========== PDF IMPORT ==========
  Future<void> _processPdfFile(String path) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    _showLoading(l10n.readingImage);
    try {
      final result = await OcrService.instance.processPdf(path, onProgress: (current, total) {
        if (mounted) _showLoading(l10n.scanProgress(current, total));
      });

      if (result.isEmpty) {
        _hideLoading();
        _showError(l10n.scanNoTextPdf);
        return;
      }

      if (result.text.trim().length < 20) {
        _hideLoading();
        _showError(l10n.scanLittleTextPdf(result.text.trim().length));
        return;
      }

      _showLoading(l10n.parsingRecipe);

      // Try multi-recipe parser first — handles cookbook PDFs with many recipes.
      // Pass per-page metadata so each recipe gets a cover image extracted from
      // the PDF page where it starts. Falls back to single-recipe parse if only
      // one recipe is detected.
      final recipes = RecipeImportEngine.parseOcrTextMulti(
        result.text,
        pageImagePaths: result.pageImagePaths,
        pageStartLines: result.pageStartLines,
        pageImageScores: result.pageImageScores,
      );

      // A scan nothing could be made of: no ingredient and no step in any of
      // the recipes.
      if (!recipes.any(hasRecipeContent)) {
        _hideLoading();
        _showError(l10n.scanNoRecipePdf);
        return;
      }

      // Use filename as fallback title only when there's a single result
      // (otherwise each recipe should keep its own recovered title)
      if (recipes.length == 1) {
        final r = recipes.first;
        r.parseConfidence = _lowerConfidence(r.parseConfidence, result.confidence);
        r.rawOcrText = result.text;
        if (RecipeImportEngine.isTitleSuspicious(r.title)) {
          r.title = p.basenameWithoutExtension(path).replaceAll(RegExp(r'[-_]'), ' ');
        }
        // For single-recipe PDFs, use the highest-scoring page image as cover.
        // Skip null entries (pages with no extractable photo).
        if (r.imagePath == null || r.imagePath!.isEmpty) {
          String? best;
          double bestScore = -1;
          for (var p = 0; p < result.pageImagePaths.length; p++) {
            final path = result.pageImagePaths[p];
            if (path == null) continue;
            final score = p < result.pageImageScores.length ? result.pageImageScores[p] : 0.0;
            if (score > bestScore) {
              bestScore = score;
              best = path;
            }
          }
          if (best != null) r.imagePath = best;
        }
      } else {
        // Number recipes that survived with bad titles — better than showing
        // "Macros per serving 511 calories..." or "Ingredients (4 servings)"
        for (var i = 0; i < recipes.length; i++) {
          final r = recipes[i];
          if (RecipeImportEngine.isTitleSuspicious(r.title)) {
            final base = p.basenameWithoutExtension(path).replaceAll(RegExp(r'[-_]'), ' ');
            r.title = '$base — Recipe ${i + 1}';
          }
        }
      }

      _hideLoading();
      _showImportPreview(recipes, sourceText: result.text);
    } catch (e) {
      _hideLoading();
      _showError(l10n.failedToImport(e.toString()));
    }
  }

  // ========== IMAGE IMPORT ==========
  Future<void> _importFromImage() async {
    final l10n = AppLocalizations.of(context)!;
    final source = await Responsive.showAdaptiveSheet<ImageSource>(
      context,
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          if (supportsCamera)
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.photoTakePhoto),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: Text(l10n.photoChooseGallery),
            subtitle: Text(l10n.scanSelectPages),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ]),
      ),
    );
    if (source == null) return;

    final ocr = OcrService.instance;

    if (source == ImageSource.gallery) {
      // Multi-image selection
      final images = await ocr.pickMultipleFromGallery();
      if (images.isEmpty) return;
      _processMultipleImages(images.map((f) => f.path).toList());
    } else {
      // Camera — single shot
      final image = await ocr.pickFromCamera();
      if (image == null) return;
      _processMultipleImages([image.path]);
    }
  }

  Future<void> _processMultipleImages(List<String> imagePaths) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    _showLoading(imagePaths.length > 1
        ? l10n.scanProgress(1, imagePaths.length)
        : l10n.readingImage);
    try {
      final result = await OcrService.instance.processMultipleImages(
        imagePaths,
        onProgress: (current, total) {
          if (mounted) _showLoading(l10n.scanProgress(current, total));
        },
      );

      if (result.isEmpty) {
        _hideLoading();
        _showError(l10n.scanNoTextImage);
        return;
      }

      if (result.text.trim().length < 20) {
        _hideLoading();
        _showError(l10n.scanLittleTextImage(result.text.trim().length));
        return;
      }

      _showLoading(l10n.parsingRecipe);

      // Try multi-recipe parser first — handles photos of cookbook pages where
      // multiple recipes appear in one batch. Falls back to single-recipe if
      // the text only looks like one recipe.
      final recipes = RecipeImportEngine.parseOcrTextMulti(result.text);

      if (!recipes.any(hasRecipeContent)) {
        _hideLoading();
        _showError(l10n.scanNoRecipeImage);
        return;
      }

      // A picked photo is a file on this device, so it goes in imagePath and
      // the save copies it out of the picker's temp folder. imageUrl is for
      // web addresses only.
      if (recipes.length == 1) {
        // Single-recipe path — use the first picked image as the cover
        final r = recipes.first;
        r.imagePath = imagePaths.first;
        r.parseConfidence = _lowerConfidence(r.parseConfidence, result.confidence);
        r.rawOcrText = result.text;
      } else {
        // Multi-recipe path — assign each image as a cover round-robin
        // (best-effort; user can swap covers in preview)
        for (var i = 0; i < recipes.length; i++) {
          recipes[i].imagePath = imagePaths[i % imagePaths.length];
        }
      }

      _hideLoading();
      _showImportPreview(recipes, sourceText: result.text);
    } catch (e) {
      _hideLoading();
      _showError(l10n.failedProcessImage(e.toString()));
    }
  }

  // ========== TEXT IMPORT ==========
  Future<void> _importFromText() async {
    final l10n = AppLocalizations.of(context)!;
    final text = await Responsive.showAdaptiveSheet<String>(
      context,
      builder: (ctx) => const _TextInputSheet(),
    );
    if (text == null || text.isEmpty) return;

    _showLoading(l10n.parsingRecipe);
    try {
      // Try multi-recipe parser — pasted text might be a whole cookbook section
      final recipes = RecipeImportEngine.parseTextMulti(text);
      _hideLoading();
      if (!recipes.any(hasRecipeContent)) {
        _showError(l10n.importNoRecipeInText);
        return;
      }
      _showImportPreview(recipes, sourceText: text);
    } catch (e) {
      _hideLoading();
      _showError(l10n.failedToParse(e.toString()));
    }
  }

  // ========== FILE IMPORT ==========

  /// A picked photo is read with the text recognition, the way the Photo
  /// tile does it. Taken apart as text it would be offered as a recipe made
  /// of noise.
  static const _photoExtensions = {'jpg', 'jpeg', 'png', 'heic', 'heif', 'webp', 'bmp', 'gif'};

  Future<void> _importFromFile() async {
    final l10n = AppLocalizations.of(context)!;
    final PlatformFile file;
    try {
      // Use FileType.any because Android doesn't recognize custom extensions.
      // In the browser a picked file has no path, so it has to come with its
      // bytes. Anywhere else it is read from its path, and asking the picker
      // for the bytes too would hold a large export in memory twice.
      final result = await FilePicker.platform.pickFiles(type: FileType.any, withData: isWeb);
      if (result == null || result.files.isEmpty) return;
      file = result.files.first;
    } catch (_) {
      _showError(l10n.importFileUnreadable);
      return;
    }
    if (!mounted) return;

    // The bytes are looked at first and the path only when there are none:
    // in the browser even asking for the path throws.
    final picked = file.bytes;
    final path = picked == null && !isWeb ? file.path : null;
    final ext = p.extension(file.name).replaceFirst('.', '').toLowerCase();

    // PDF is handled separately (OCR flow), and so is a photo. Both need the
    // text recognition of a phone and a file on the device to point it at.
    // How the file starts tells them apart from text when the name does not:
    // IMG_2041.jfif, scan.tiff, a photo saved without an extension.
    var kind = ext == 'pdf' ? _FileKind.pdf : (_photoExtensions.contains(ext) ? _FileKind.photo : null);
    kind ??= _kindOf(picked ?? await _startOf(path));
    if (!mounted) return;
    if (kind != null) {
      if (!supportsOcr) {
        _showError(kind == _FileKind.pdf ? l10n.importPdfMobileOnly : l10n.importPhotoMobileOnly);
      } else if (path == null) {
        // The mobile app reads them, but the picker gave no file to read.
        _showError(l10n.importFileUnreadable);
      } else if (kind == _FileKind.pdf) {
        _processPdfFile(path);
      } else {
        _processMultipleImages([path]);
      }
      return;
    }

    _processFileWithDispatcher(file.name, bytes: picked, path: path);
  }

  /// The first bytes of the file at [path], or nothing when it cannot be
  /// read.
  static Future<List<int>> _startOf(String? path) async {
    if (path == null) return const [];
    try {
      final start = <int>[];
      await for (final chunk in File(path).openRead(0, 16)) {
        start.addAll(chunk);
      }
      return start;
    } catch (_) {
      return const [];
    }
  }

  /// A PDF or a photo, by how [bytes] start, or null for anything else.
  static _FileKind? _kindOf(List<int> bytes) {
    bool has(int offset, List<int> signature) {
      if (bytes.length < offset + signature.length) return false;
      for (var i = 0; i < signature.length; i++) {
        if (bytes[offset + i] != signature[i]) return false;
      }
      return true;
    }

    if (has(0, '%PDF-'.codeUnits)) return _FileKind.pdf;
    final photo = has(0, const [0xFF, 0xD8, 0xFF]) ||
        has(0, const [0x89, 0x50, 0x4E, 0x47]) ||
        has(0, 'GIF8'.codeUnits) ||
        (has(0, 'RIFF'.codeUnits) && has(8, 'WEBP'.codeUnits)) ||
        has(0, const [0x49, 0x49, 0x2A, 0x00]) ||
        has(0, const [0x4D, 0x4D, 0x00, 0x2A]) ||
        (has(4, 'ftyp'.codeUnits) &&
            const ['heic', 'heix', 'hevc', 'mif1', 'msf1', 'avif', 'avis'].any((brand) => has(8, brand.codeUnits)));
    return photo ? _FileKind.photo : null;
  }

  void _createManually() {
    Navigator.of(context).pop();
    context.push('/cookbook/${widget.cookbookId}/new-recipe');
  }

  /// Unified file import using FileImportDispatcher.
  /// Handles all formats: ZIP-based (Paprika, Mela, Recipe Keeper, Cookmate),
  /// text-based (MasterCook, Plan to Eat CSV, Cooklang, Living Cookbook),
  /// and legacy formats (MealMaster, HTML, Markdown, etc.)
  ///
  /// The file is what the picker handed over: its [bytes], or the [path] to
  /// read them from.
  Future<void> _processFileWithDispatcher(String filename, {Uint8List? bytes, String? path}) async {
    final l10n = AppLocalizations.of(context)!;
    _showLoading(l10n.importProcessing);
    if (bytes == null && path != null) {
      try {
        bytes = await File(path).readAsBytes();
      } catch (_) {
        // Told below, like a file that came with nothing to read.
      }
    }
    if (bytes == null) {
      _hideLoading();
      _showError(l10n.importFileUnreadable);
      return;
    }
    try {
      // JSON might be our own export format: check first
      if (p.extension(filename).toLowerCase() == '.json') {
        final exported = await compute(_ownExportIn, bytes);
        if (exported != null) {
          _hideLoading();
          _processOwnExportFormat(exported, nothingFound: l10n.importNoRecipeInFile);
          return;
        }
      }

      final recipes = await FileImportDispatcher.importFromBytes(bytes, filename);

      _hideLoading();
      if (!recipes.any(hasRecipeContent)) {
        _showError(l10n.importNoRecipeInFile);
        return;
      }
      _showImportPreview(recipes);
    } catch (e) {
      _hideLoading();
      // What an importer could not read, it says in a sentence of its own,
      // and that sentence is the message.
      _showError(e is FormatException && e.message.trim().isNotEmpty ? e.message : l10n.failedToImport(e.toString()));
    }
  }

  /// Handle Recipe Spellbook's own JSON export format: a cookbook export or
  /// a backup. Its [recipes] go through the preview like any others, into the
  /// cookbook that is open, and keep everything the file says about them.
  void _processOwnExportFormat(List<ImportedRecipe> recipes, {required String nothingFound}) {
    if (!recipes.any(hasRecipeContent)) {
      _showError(nothingFound);
      return;
    }
    _showImportPreview(recipes, sourceText: 'Recipe Spellbook export (${recipes.length} recipes)');
  }

  void _showImportPreview(List<ImportedRecipe> recipes, {String? sourceUrl, String? sourceText}) {
    if (!mounted) return;
    // Navigate to the full import preview screen
    Navigator.of(context).pop(); // Close the new recipe dialog first
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ImportPreviewScreen(
          recipes: recipes,
          cookbookId: widget.cookbookId,
          sourceUrl: sourceUrl,
          sourceText: sourceText,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: SheetPresentation.surfaceRadius(context),
      ),
      child: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SheetHandle(top: 0),
                  const SizedBox(height: 22),

                  // ── Header ──
                  Text('Add a recipe', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    'Paste a link from Instagram, TikTok, a website, anywhere.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),

                  // Fancy supported-platform strip
                  const PlatformLogoStrip(),
                  const SizedBox(height: 22),

                  // ── Hero: paste a link ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Live "Instagram link" detection chip
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, anim) => SizeTransition(
                            sizeFactor: anim,
                            axisAlignment: -1,
                            child: FadeTransition(opacity: anim, child: child),
                          ),
                          child: _detected == null
                              ? const SizedBox(width: double.infinity)
                              : Padding(
                                  key: ValueKey(_detected),
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: PlatformBadge(_detected!,
                                        compact: true,
                                        labelOverride: '${platformInfo(_detected!).name} link'),
                                  ),
                                ),
                        ),
                        // URL field + big Paste button
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _urlController,
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.go,
                                onSubmitted: (_) => _importFromUrl(),
                                style: theme.textTheme.bodyLarge,
                                decoration: InputDecoration(
                                  hintText: 'Paste a recipe link…',
                                  prefixIcon: const Icon(Icons.link_rounded),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.colorScheme.primary, width: 2)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Semantics(
                              button: true,
                              label: 'Paste link from clipboard',
                              child: Material(
                                color: theme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  onTap: _pasteUrl,
                                  borderRadius: BorderRadius.circular(16),
                                  child: SizedBox(
                                    height: 56,
                                    width: 56,
                                    child: Icon(Icons.content_paste_rounded, color: theme.colorScheme.onSecondaryContainer),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Big, high-contrast primary action
                        Semantics(
                          button: true,
                          label: _detected == null
                              ? 'Import recipe from link'
                              : 'Import from ${platformInfo(_detected!).name}',
                          child: SizedBox(
                            height: 56,
                            child: FilledButton.icon(
                              onPressed: () { HapticFeedback.lightImpact(); _importFromUrl(); },
                              icon: const Icon(Icons.download_rounded),
                              label: Text(
                                (_detected == null || _detected == RecipePlatform.website)
                                    ? 'Import recipe'
                                    : 'Import from ${platformInfo(_detected!).name}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                              style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // "or another way"
                  Row(children: [
                    Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Text('or another way', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
                    Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
                  ]),
                  const SizedBox(height: 16),

                  // Secondary options — big, labeled tiles that wrap
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      if (supportsOcr)
                        _ImportOptionTile(icon: Icons.photo_camera_rounded, label: 'Photo', color: theme.colorScheme.tertiary, onTap: _importFromImage),
                      // Many pages of a printed cookbook in one sitting.
                      if (supportsBookScan && canAddRecipesTo(widget.cookbookId))
                        _ImportOptionTile(icon: Icons.document_scanner_rounded, label: l10n.bookScanTile, color: theme.colorScheme.secondary, onTap: () {
                          // The sheet closes first, so start from a context
                          // that outlives it.
                          final root = Navigator.of(context, rootNavigator: true).context;
                          Navigator.pop(context);
                          startBookScan(root, cookbookId: widget.cookbookId);
                        }),
                      _ImportOptionTile(icon: Icons.notes_rounded, label: 'Paste text', color: theme.colorScheme.primary, onTap: _importFromText),
                      _ImportOptionTile(icon: Icons.folder_open_rounded, label: 'File', color: theme.colorScheme.secondary, onTap: _importFromFile),
                      _ImportOptionTile(icon: Icons.auto_awesome_rounded, label: 'AI', color: theme.colorScheme.tertiary, onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => AiImportScreen(cookbookId: widget.cookbookId)));
                      }),
                      if (supportsBarcodeScanner)
                        _ImportOptionTile(icon: Icons.qr_code_scanner_rounded, label: 'Scan', color: theme.colorScheme.primary, onTap: _importFromBarcode),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Help + manual (quiet)
                  Row(
                    children: [
                      Expanded(
                        child: _MiniLink(
                          icon: Icons.help_outline_rounded,
                          label: 'How to import',
                          onTap: () {
                            // Desktop: open the guides in-shell (sidebar stays).
                            final desktop = Responsive.isDesktopLayout(context);
                            final router = GoRouter.of(context);
                            Navigator.pop(context);
                            if (desktop) {
                              router.push('/import-guides');
                            } else {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ImportGuidesScreen()));
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniLink(
                          icon: Icons.edit_outlined,
                          label: 'Type it in',
                          onTap: _createManually,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay — shows the platform we're grabbing from
          if (_isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.96),
                  borderRadius: SheetPresentation.surfaceRadius(context),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_detected != null && _detected != RecipePlatform.website) ...[
                      PlatformLogo(_detected!, size: 56),
                      const SizedBox(height: 20),
                    ],
                    const SizedBox(width: 34, height: 34, child: CircularProgressIndicator(strokeWidth: 3)),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        (_detected != null && _detected != RecipePlatform.website)
                            ? 'Grabbing the recipe from ${platformInfo(_detected!).name}…'
                            : (_loadingMessage ?? l10n.loadingText),
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============ HELPER WIDGETS ============

/// Large, clearly-labeled secondary import option (Photo / Text / File / AI /
/// Scan). Big touch target + semantics + haptic for easy, accessible tapping.
class _ImportOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ImportOptionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: 92,
        child: Material(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () { HapticFeedback.selectionClick(); onTap(); },
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.18), shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Quiet, full-width secondary link row (help / manual entry).
class _MiniLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MiniLink({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============ TEXT INPUT SHEET ============

class _TextInputSheet extends StatefulWidget {
  const _TextInputSheet();
  @override
  State<_TextInputSheet> createState() => _TextInputSheetState();
}

class _TextInputSheetState extends State<_TextInputSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) setState(() => _controller.text = data!.text!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: SheetPresentation.surfaceRadius(context)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: const SheetHandle(top: 0)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: Text(l10n.pasteRecipeTitle, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
              TextButton.icon(onPressed: _paste, icon: const Icon(Icons.content_paste, size: 18), label: Text(l10n.actionPaste)),
            ]),
            const SizedBox(height: 16),
            Flexible(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: l10n.pasteRecipeHint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), alignLabelWithHint: true),
                maxLines: null, minLines: 10, autofocus: true,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () { final text = _controller.text.trim(); Navigator.pop(context, text.isEmpty ? null : text); },
              icon: const Icon(Icons.auto_fix_high),
              label: Text(l10n.parseRecipe),
            ),
          ],
        ),
      ),
    );
  }
}