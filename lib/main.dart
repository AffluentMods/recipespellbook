import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_handler/share_handler.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/cookbook_provider.dart';
import 'providers/database_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/sync_provider.dart';
import 'router/router.dart';
import 'services/ingredient_suggestion_service.dart';
import 'services/notification_service.dart';
import 'services/ocr_service.dart';
import 'services/recipe_import_engine.dart';
import 'services/sync_service.dart';
import 'services/transfer_service.dart';
import 'theme/app_theme.dart';
import 'ui/screens/import/import_preview_screen.dart';

// Provider to hold shared recipe data (for future share intent)
final sharedRecipeProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('[Firebase] Initialization failed: $e');
  }
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  IngredientSuggestionService.instance.preload();
  runApp(const ProviderScope(child: RecipeSpellbookApp()));
}

class RecipeSpellbookApp extends ConsumerWidget {
  const RecipeSpellbookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorTheme = ref.watch(appColorThemeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final settings = ref.watch(settingsProvider);
    final textScale = ref.watch(textScaleProvider);

    final Locale? locale = settings.languageCode == 'system'
        ? null
        : Locale(settings.languageCode);

    return _AppLifecycleManager(
      child: MaterialApp.router(
        title: 'Recipe Spellbook',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          if (locale != null) return locale;
          if (deviceLocale != null) {
            for (final supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == deviceLocale.languageCode) {
                return supportedLocale;
              }
            }
          }
          return const Locale('en');
        },
        theme: AppTheme.lightTheme(colorTheme),
        darkTheme: AppTheme.darkTheme(colorTheme),
        themeMode: themeMode,
        routerConfig: router,
        // ── Text scale — applies user's accessibility preference globally ──
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}

class _AppLifecycleManager extends ConsumerStatefulWidget {
  final Widget child;
  const _AppLifecycleManager({required this.child});

  @override
  ConsumerState<_AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends ConsumerState<_AppLifecycleManager>
    with WidgetsBindingObserver {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Delay to avoid modifying providers during widget tree build
    WidgetsBinding.instance.addPostFrameCallback((_) => _initServices());
  }

  Future<void> _initServices() async {
    // 1. Wire services to database
    final db = ref.read(databaseProvider);
    SyncService.instance.setDatabase(db);
    TransferService.instance.setDatabase(db);

    // 2. Restore auth session (must be first — determines signed-in state)
    await ref.read(authProvider.notifier).initialize();

    // 3. Remove splash screen — show the app while the rest loads in background
    FlutterNativeSplash.remove();

    _initialized = true;

    // 4. Initialize subscription + notifications in parallel (non-blocking).
    //    Subscription defaults to free tier and updates once RevenueCat responds.
    //    Notification service sets up channels and foreground listeners.
    _initBackground();

    // 5. Auto-sync on launch if eligible
    ref.read(syncProvider.notifier).autoSync();

    // 6. Wire up share intent handling
    _initShareHandler();
  }

  /// Initialize subscription + notifications in background (non-blocking).
  /// These don't need to complete before the user sees the app.
  Future<void> _initBackground() async {
    try {
      await Future.wait([
        ref.read(subscriptionProvider.notifier).initialize(),
        NotificationService.instance.initialize(),
      ]);
    } catch (e) {
      debugPrint('[Init] Background init error: $e');
    }
  }

  // ── Share intent handling ──────────────────────────────────────────
  void _initShareHandler() {
    final handler = ShareHandlerPlatform.instance;

    // Cold start — app was launched via share
    handler.getInitialSharedMedia().then((SharedMedia? media) {
      if (media != null) _handleSharedMedia(media);
    });

    // Warm start — app already running, user shares to it
    handler.sharedMediaStream.listen((SharedMedia media) {
      _handleSharedMedia(media);
    });
  }

  void _handleSharedMedia(SharedMedia media) {
    // 1. Check for shared images (photos of recipes)
    if (media.attachments != null && media.attachments!.isNotEmpty) {
      final imagePaths = <String>[];
      for (final a in media.attachments!) {
        if (a != null && a.path != null && _isImagePath(a.path!)) {
          imagePaths.add(a.path!);
        }
      }
      if (imagePaths.isNotEmpty) {
        _importFromSharedImages(imagePaths);
        return;
      }
    }

    // 2. Check for shared text/URL
    final content = media.content?.trim();
    if (content != null && content.isNotEmpty) {
      final url = _extractUrl(content);
      if (url != null) {
        _importFromSharedUrl(url);
        return;
      }

      // Non-URL text — try to parse as a recipe
      _importFromSharedText(content);
    }
  }

  bool _isImagePath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') || lower.endsWith('.jpeg') ||
           lower.endsWith('.png') || lower.endsWith('.heic') ||
           lower.endsWith('.webp') || lower.endsWith('.bmp');
  }

  /// Process shared images through OCR and navigate to preview.
  Future<void> _importFromSharedImages(List<String> imagePaths) async {
    final nav = rootNavigatorKey.currentState;
    if (nav == null) return;

    final cookbookAsync = ref.read(selectedCookbookProvider);
    final cookbookId = cookbookAsync.valueOrNull?.id ?? 'starter';

    // Show loading overlay
    showDialog(
      context: nav.context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Scanning ${imagePaths.length} image${imagePaths.length > 1 ? 's' : ''}...',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      final ocrResult = await OcrService.instance.processMultipleImages(imagePaths);

      // Dismiss loading
      if (nav.canPop()) nav.pop();

      if (ocrResult.isEmpty) {
        if (nav.context.mounted) {
          ScaffoldMessenger.of(nav.context).showSnackBar(
            const SnackBar(
              content: Text('No text found in the shared image. Try a clearer photo or paste text instead.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final recipe = RecipeImportEngine.parseOcrText(ocrResult.text);
      recipe.parseConfidence = ocrResult.confidence;
      recipe.rawOcrText = ocrResult.text;

      nav.push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => ImportPreviewScreen(
            recipes: [recipe],
            cookbookId: cookbookId,
            sourceText: ocrResult.text,
          ),
        ),
      );
    } catch (e) {
      if (nav.canPop()) nav.pop();
      if (nav.context.mounted) {
        ScaffoldMessenger.of(nav.context).showSnackBar(
          SnackBar(
            content: Text('Failed to scan image: ${e.toString().replaceFirst("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Process shared text as a recipe and navigate to preview.
  Future<void> _importFromSharedText(String text) async {
    final nav = rootNavigatorKey.currentState;
    if (nav == null) return;

    final cookbookAsync = ref.read(selectedCookbookProvider);
    final cookbookId = cookbookAsync.valueOrNull?.id ?? 'starter';

    final recipe = RecipeImportEngine.parseFromText(text);

    // Only proceed if we found something useful
    if (recipe.ingredients.isEmpty && recipe.instructions.isEmpty && recipe.title == 'Untitled Recipe') {
      return; // Not a recipe, ignore
    }

    nav.push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ImportPreviewScreen(
          recipes: [recipe],
          cookbookId: cookbookId,
          sourceText: text,
        ),
      ),
    );
  }

  /// Parses a shared URL and navigates directly to ImportPreviewScreen.
  Future<void> _importFromSharedUrl(String url) async {
    final nav = rootNavigatorKey.currentState;
    if (nav == null) return;

    // Ensure https prefix
    String finalUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      finalUrl = 'https://$url';
    }

    // Get the active cookbook ID
    final cookbookAsync = ref.read(selectedCookbookProvider);
    final cookbookId = cookbookAsync.valueOrNull?.id ?? 'starter';

    // Show a loading overlay
    final l10n = AppLocalizations.of(nav.context)!;
    showDialog(
      context: nav.context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.importingRecipe, style: const TextStyle(fontWeight: FontWeight.w500))
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      final recipe = await RecipeImportEngine.parseFromUrl(finalUrl);

      // Dismiss loading dialog
      if (nav.canPop()) nav.pop();

      // Navigate to preview screen
      nav.push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => ImportPreviewScreen(
            recipes: [recipe],
            cookbookId: cookbookId,
            sourceUrl: finalUrl,
          ),
        ),
      );
    } catch (e) {
      // Dismiss loading dialog
      if (nav.canPop()) nav.pop();

      // Show error snackbar
      final ctx = nav.context;
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToImport(e.toString().replaceFirst("Exception: ", ""))),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Extracts the first URL from shared text.
  /// Handles cases like "Check out this recipe! https://example.com/recipe"
  String? _extractUrl(String text) {
    final urlPattern = RegExp(
      r'https?://[^\s<>"{}|\\^`\[\]]+',
      caseSensitive: false,
    );
    final match = urlPattern.firstMatch(text);
    return match?.group(0);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _initialized) {
      // Auto-sync when app comes back to foreground
      ref.read(syncProvider.notifier).autoSync();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}