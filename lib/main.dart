import 'dart:async';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'services/notification_stub.dart' if (dart.library.io) 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utils/share_handler_stub.dart' if (dart.library.io) 'package:share_handler/share_handler.dart';
import 'l10n/app_localizations.dart';
import 'utils/platform_utils.dart';
import 'providers/auth_provider.dart';
import 'providers/cookbook_provider.dart';
import 'providers/database_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/sync_provider.dart';
import 'router/router.dart';
import 'package:app_links/app_links.dart';
import 'services/ingredient_suggestion_service.dart';
import 'services/notification_service.dart';
import 'services/ocr_service.dart';
import 'services/recipe_import_engine.dart';
import 'services/desktop_window_service.dart';
import 'services/sync_service.dart';
import 'services/transfer_service.dart';
import 'services/collab_service.dart';
import 'theme/app_theme.dart';
import 'ui/screens/import/import_preview_screen.dart';
import 'ui/widgets/app_shortcuts.dart';

/// Custom scroll behavior that enables mouse drag scrolling for horizontal
/// lists on desktop (trackpad, mouse, stylus all work like touch).
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

Future<void> main() async {
  // Global error boundary — catch uncaught async errors
  runZonedGuarded(() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

    // Catch uncaught Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('[FlutterError] ${details.exceptionAsString()}');
    };

    try {
      if (supportsFirebaseMessaging) {
        await Firebase.initializeApp();
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      }
    } catch (e) {
      debugPrint('[Firebase] Initialization failed: $e');
    }
    if (supportsNativeSplash) {
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    }

    // Desktop window management (min size, title, restore position)
    await DesktopWindowService.initialize();

    // Preload ingredient suggestions (fire-and-forget with error handling)
    try {
      IngredientSuggestionService.instance.preload();
    } catch (e) {
      debugPrint('[Init] Ingredient preload failed: $e');
    }

    runApp(const ProviderScope(child: RecipeSpellbookApp()));
  }, (error, stack) {
    debugPrint('[Uncaught] $error\n$stack');
  });
}

class RecipeSpellbookApp extends ConsumerWidget {
  const RecipeSpellbookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorTheme = ref.watch(appColorThemeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final settings = ref.watch(settingsProvider);
    final textScale = ref.watch(textScaleProvider);
    final customPalettes = ref.watch(customThemePalettesProvider);

    final Locale? locale = settings.languageCode == 'system'
        ? null
        : Locale(settings.languageCode);

    return _AppLifecycleManager(
      child: MaterialApp.router(
        title: 'Recipe Spellbook',
        scrollBehavior: AppScrollBehavior(),
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
        theme: AppTheme.lightTheme(colorTheme, customPalette: customPalettes?.light),
        darkTheme: AppTheme.darkTheme(colorTheme, customPalette: customPalettes?.dark),
        themeMode: themeMode,
        routerConfig: router,
        // ── Text scale + keyboard shortcuts ──
        builder: (context, child) {
          Widget result = MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
            ),
            child: AppShortcuts(child: child!),
          );

          // Scale up touch targets on tablets/desktop
          final screenWidth = MediaQuery.of(context).size.width;
          if (screenWidth >= 600) {
            final baseTheme = Theme.of(context);
            final tabletPadding = screenWidth >= 900
                ? const EdgeInsets.symmetric(horizontal: 32, vertical: 16)
                : const EdgeInsets.symmetric(horizontal: 28, vertical: 14);
            final tabletMinSize = screenWidth >= 900
                ? const Size(88, 52)
                : const Size(80, 48);

            result = Theme(
              data: baseTheme.copyWith(
                filledButtonTheme: FilledButtonThemeData(
                  style: (baseTheme.filledButtonTheme.style ?? const ButtonStyle()).copyWith(
                    padding: WidgetStatePropertyAll(tabletPadding),
                    minimumSize: WidgetStatePropertyAll(tabletMinSize),
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: (baseTheme.elevatedButtonTheme.style ?? const ButtonStyle()).copyWith(
                    padding: WidgetStatePropertyAll(tabletPadding),
                    minimumSize: WidgetStatePropertyAll(tabletMinSize),
                  ),
                ),
                outlinedButtonTheme: OutlinedButtonThemeData(
                  style: (baseTheme.outlinedButtonTheme.style ?? const ButtonStyle()).copyWith(
                    padding: WidgetStatePropertyAll(tabletPadding),
                    minimumSize: WidgetStatePropertyAll(tabletMinSize),
                  ),
                ),
                listTileTheme: baseTheme.listTileTheme.copyWith(
                  minVerticalPadding: screenWidth >= 900 ? 12 : 10,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth >= 900 ? 24 : 20,
                  ),
                ),
              ),
              child: result,
            );
          }

          return result;
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
    CollabService.instance.setDatabase(db);
    CollabService.instance.load();

    // 2. Restore auth session (must be first — determines signed-in state)
    await ref.read(authProvider.notifier).initialize();

    // 3. Remove splash screen — show the app while the rest loads in background.
    // Unguarded: on web this removes the static HTML splash overlay from
    // index.html (which otherwise covers the app until home_screen builds);
    // on mobile/desktop it dismisses the native splash. Safe everywhere.
    FlutterNativeSplash.remove();

    _initialized = true;

    // 4. Initialize subscription + notifications (must complete before auto-sync
    //    so subscription tier is known — otherwise sync sees "free" and bails).
    await _initBackground();

    // 5. Auto-sync on launch if eligible (after subscription is resolved)
    ref.read(syncProvider.notifier).autoSync();

    // 6. Auto-cleanup trashed recipes older than 30 days
    ref.read(recipeDaoProvider).cleanupOldDeletedRecipes().catchError((e) {
      debugPrint('[Init] Trash cleanup failed: $e');
    });

    // 7. Wire up share intent handling
    _initShareHandler();

    // 8. Wire up deep links (recipe/cookbook/list share view links)
    _initDeepLinks();
  }

  // ── Deep-link handling (share view links) ──────────────────────────
  //  Handles: recipespellbook://import?code=ABC  (web "Open in App")
  //           recipespellbook://s/ABC
  //           https://recipespellbook.app/s/ABC  (universal link, if verified)
  AppLinks? _deepLinks;
  StreamSubscription<Uri>? _deepLinkSub;

  Future<void> _initDeepLinks() async {
    try {
      _deepLinks = AppLinks();
      final initial = await _deepLinks!.getInitialAppLink();
      if (initial != null) _handleDeepLink(initial);
      _deepLinkSub = _deepLinks!.uriLinkStream.listen(
        _handleDeepLink,
        onError: (Object e) => debugPrint('[DeepLink] stream error: $e'),
      );
    } catch (e) {
      debugPrint('[DeepLink] init failed: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    final code = _shareCodeFromUri(uri);
    if (code == null || code.isEmpty) return;
    // Open the public share viewer (no auth required).
    router.push('/s/$code');
  }

  /// Pull a share code out of the various link shapes we accept.
  String? _shareCodeFromUri(Uri uri) {
    final q = uri.queryParameters['code'];
    if (q != null && q.isNotEmpty) return q;
    // Look for a `/s/<code>` segment (host counts as the first segment for
    // custom-scheme links like recipespellbook://s/<code>).
    final segs = [uri.host, ...uri.pathSegments].where((s) => s.isNotEmpty).toList();
    final i = segs.indexOf('s');
    if (i >= 0 && i + 1 < segs.length) return segs[i + 1];
    return null;
  }

  /// Initialize subscription + notifications in background (non-blocking).
  /// These don't need to complete before the user sees the app.
  Future<void> _initBackground() async {
    try {
      final futures = <Future>[
        ref.read(subscriptionProvider.notifier).initialize(),
      ];
      if (supportsFirebaseMessaging) {
        futures.add(NotificationService.instance.initialize());
      }
      await Future.wait(futures);
    } catch (e) {
      debugPrint('[Init] Background init error: $e');
    }
  }

  // ── Share intent handling ──────────────────────────────────────────
  void _initShareHandler() {
    if (!supportsShareHandler) return;
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
        if (a != null && _isImagePath(a.path)) {
          imagePaths.add(a.path);
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