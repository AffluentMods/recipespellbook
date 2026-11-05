import 'dart:async';
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database.dart';
import '../l10n/app_localizations.dart';
import '../utils/platform_utils.dart';
import 'home_widget_snapshot.dart';

/// Keeps the home screen widgets (Today's meals, Shopping list) up to date.
///
/// The app is the only writer: whenever meal plans, recipes or shopping items
/// change (debounced), and when the app starts, resumes or goes to the
/// background, it rebuilds the [HomeWidgetSnapshot], writes it to the shared
/// widget storage when it changed, and asks both widgets to redraw.
///
/// Storage is home_widget's: SharedPreferences "HomeWidgetPreferences" on
/// Android, the App Group's UserDefaults ([iosAppGroupId]) on iOS.
class HomeWidgetService {
  HomeWidgetService({
    Future<void> Function(String snapshotJson)? publish,
    DateTime Function()? clock,
    this.debounce = const Duration(milliseconds: 800),
  })  : _publish = publish ?? _publishToPlatform,
        _clock = clock ?? DateTime.now;

  static final instance = HomeWidgetService();

  /// App Group shared by the Runner app and the RecipeWidgets extension.
  /// Must match ios/RecipeWidgets/RecipeWidgets.entitlements, the Runner's
  /// App Groups capability and `WidgetSnapshot.appGroup` in the extension.
  static const iosAppGroupId = 'group.com.affluentlabs.recipespellbook';

  static const androidMealsProvider =
      'com.affluentlabs.recipespellbook.widgets.TodaysMealsWidgetProvider';
  static const androidShoppingProvider =
      'com.affluentlabs.recipespellbook.widgets.ShoppingListWidgetProvider';

  /// WidgetKit kinds, as declared in ios/RecipeWidgets.
  static const iosMealsKind = 'TodaysMealsWidget';
  static const iosShoppingKind = 'ShoppingListWidget';

  final Future<void> Function(String snapshotJson) _publish;
  final DateTime Function() _clock;

  /// How long a burst of database writes is collected before one refresh.
  final Duration debounce;

  AppDatabase? _db;
  String Function() _languageCode = () => 'system';
  StreamSubscription<Object?>? _tableSub;
  Timer? _debounceTimer;
  Future<void>? _inFlight;
  bool _rerun = false;
  String? _lastPublished;

  /// Only Android and iOS have home screen widgets.
  static bool get isSupported => supportsHomeWidgets;

  /// Starts watching [db] and writes a first snapshot. [languageCode] returns
  /// the app's language setting ('system' or a language code) so the widgets
  /// use the same language as the app.
  Future<void> start(AppDatabase db, {required String Function() languageCode}) async {
    _db = db;
    _languageCode = languageCode;
    await _tableSub?.cancel();
    _tableSub = db
        .tableUpdates(TableUpdateQuery.onAllTables([
          db.mealPlans,
          db.recipes,
          db.shoppingLists,
          db.shoppingListItems,
        ]))
        .listen((_) => scheduleRefresh());
    await refresh();
  }

  /// Stops watching the database. Pending refreshes are dropped.
  Future<void> stop() async {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    await _tableSub?.cancel();
    _tableSub = null;
    _db = null;
  }

  /// Refresh after [debounce], folding any further calls in that window into
  /// the same refresh.
  void scheduleRefresh() {
    if (_db == null) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () {
      _debounceTimer = null;
      refresh();
    });
  }

  /// Rebuild the snapshot now and publish it if it changed. Calls that arrive
  /// while one is running are folded into a single follow-up run.
  Future<void> refresh() {
    if (_db == null) return Future.value();
    final running = _inFlight;
    if (running != null) {
      _rerun = true;
      return running;
    }
    final run = _refreshOnce().whenComplete(() {
      _inFlight = null;
      if (_rerun) {
        _rerun = false;
        refresh();
      }
    });
    _inFlight = run;
    return run;
  }

  Future<void> _refreshOnce() async {
    final db = _db;
    if (db == null) return;
    try {
      final l10n = lookupAppLocalizations(
        resolveLocale(_languageCode(), PlatformDispatcher.instance.locale),
      );
      final prefs = await SharedPreferences.getInstance();
      final snapshot = await HomeWidgetSnapshot.load(
        db,
        now: _clock(),
        preferredListId: prefs.getString(shoppingLastListPrefKey),
        labels: HomeWidgetLabels(
          mealsTitle: l10n.widgetTodaysMealsTitle,
          mealsEmpty: l10n.widgetTodaysMealsEmpty,
          shoppingTitle: l10n.widgetShoppingListTitle,
          shoppingEmpty: l10n.widgetShoppingListEmpty,
        ),
        mealTypeLabel: (type) => mealTypeLabel(l10n, type),
      );
      final json = HomeWidgetSnapshot.encode(snapshot);
      if (json == _lastPublished) return;
      await _publish(json);
      _lastPublished = json;
    } catch (e) {
      debugPrint('[HomeWidget] refresh failed: $e');
    }
  }

  /// The supported locale for the app's language setting: the chosen
  /// language, or the phone's when it is 'system', else English.
  static Locale resolveLocale(String languageCode, Locale platformLocale) {
    final wanted = languageCode == 'system' ? platformLocale.languageCode : languageCode;
    for (final l in AppLocalizations.supportedLocales) {
      if (l.languageCode == wanted) return l;
    }
    return const Locale('en');
  }

  /// The meal type in the app's words. Custom meal types are the user's own
  /// text and stay as they are. (Same mapping as the planner's.)
  static String mealTypeLabel(AppLocalizations l10n, String type) => switch (type) {
        'Breakfast' => l10n.mealTypeBreakfast,
        'Lunch' => l10n.mealTypeLunch,
        'Dinner' => l10n.mealTypeDinner,
        'Appetizer' => l10n.mealTypeAppetizer,
        'Dessert' => l10n.mealTypeDessert,
        'Snack' => l10n.mealTypeSnack,
        _ => type,
      };

  static bool _appGroupSet = false;

  static Future<void> _publishToPlatform(String json) async {
    if (isIOS && !_appGroupSet) {
      await HomeWidget.setAppGroupId(iosAppGroupId);
      _appGroupSet = true;
    }
    await HomeWidget.saveWidgetData<String>(homeWidgetSnapshotKey, json);
    await HomeWidget.updateWidget(
      qualifiedAndroidName: androidMealsProvider,
      iOSName: iosMealsKind,
    );
    await HomeWidget.updateWidget(
      qualifiedAndroidName: androidShoppingProvider,
      iOSName: iosShoppingKind,
    );
  }
}
