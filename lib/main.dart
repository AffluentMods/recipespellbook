import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'router/router.dart';
import 'theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const ProviderScope(child: RecipeSpellbookApp()));
}

class RecipeSpellbookApp extends ConsumerWidget {
  const RecipeSpellbookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers from app_theme.dart
    final colorTheme = ref.watch(appColorThemeProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Watch locale from settings_provider.dart
    final settings = ref.watch(settingsProvider);

    // If 'system', use null to let Flutter pick system locale
    // Otherwise use the specific locale
    final Locale? locale = settings.languageCode == 'system'
        ? null
        : Locale(settings.languageCode);

    return MaterialApp.router(
      title: 'Recipe Spellbook',
      debugShowCheckedModeBanner: false,

      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,

      // Callback to resolve locale when set to system
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        // If user selected a specific language, that's handled by locale parameter
        if (locale != null) return locale;

        // For system preference, find best match
        if (deviceLocale != null) {
          for (final supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == deviceLocale.languageCode) {
              return supportedLocale;
            }
          }
        }
        // Default to English if no match
        return const Locale('en');
      },

      // Theme
      theme: AppTheme.lightTheme(colorTheme),
      darkTheme: AppTheme.darkTheme(colorTheme),
      themeMode: themeMode,

      // Router
      routerConfig: router,
    );
  }
}