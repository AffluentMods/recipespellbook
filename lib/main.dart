import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:share_handler/share_handler.dart';
import 'router/router.dart';
import 'theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'l10n/app_localizations.dart';
import 'services/ingredient_suggestion_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/sync_service.dart';
import 'services/transfer_service.dart';
import 'providers/database_provider.dart';
import 'providers/sync_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/subscription_provider.dart';

/// Holds a URL shared from another app (e.g. Instagram, browser).
/// The URL import screen should read this on init and pre-fill its text field.
final sharedUrlProvider = StateProvider<String?>((ref) => null);

// Provider to hold shared recipe data (for future share intent)
final sharedRecipeProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
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

    // 2. Restore auth session (also syncs JWT to services)
    await ref.read(authProvider.notifier).initialize();

    // 3. Initialize subscription state from auth/backend tier
    await ref.read(subscriptionProvider.notifier).initialize();

    // 4. Remove splash screen
    FlutterNativeSplash.remove();

    _initialized = true;

    // 5. Auto-sync on launch if eligible
    ref.read(syncProvider.notifier).autoSync();

    // 6. Wire up share intent handling
    _initShareHandler();
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
    // 1. Check for shared text/URL
    final content = media.content?.trim();
    if (content != null && content.isNotEmpty) {
      final url = _extractUrl(content);
      if (url != null) {
        // Set the shared URL so the import screen can pre-fill it
        ref.read(sharedUrlProvider.notifier).state = url;
        router.push('/import/url');
        return;
      }
      // Plain text without URL — route to AI import
      ref.read(sharedUrlProvider.notifier).state = content;
      router.push('/import/ai');
      return;
    }

    // 2. Check for shared images (for OCR)
    if (media.attachments != null && media.attachments!.isNotEmpty) {
      final firstImage = media.attachments!.first;
      if (firstImage?.path != null) {
        // Store image path and route to image import
        ref.read(sharedUrlProvider.notifier).state = firstImage!.path;
        router.push('/import/ai');
        return;
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