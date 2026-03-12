import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/ui/screens/settings/pantry_screen.dart';
import '../../../data/app_enums.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
// TODO: Kitchen Buddy hidden for now
// import '../../../providers/kitchen_buddy_provider.dart';
import '../../../utils/responsive_utils.dart';

import '../../../providers/settings_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/export_import_service.dart';
import '../../../services/family_service.dart';
import '../../../services/onboarding_service.dart';
import '../../../services/sync_service.dart';
import '../home/home_screen.dart';
import '../../../services/revenuecat_service.dart';
import '../../widgets/app_snackbar.dart';
import 'custom_theme_screen.dart';
import 'nutrition_settings_screen.dart';

// ════════════════════════════════════════════════════════════
//  SETTINGS SCREEN
// ════════════════════════════════════════════════════════════

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _query = '';
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  bool _m(String title, [String extra = '']) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return title.toLowerCase().contains(q) || extra.toLowerCase().contains(q);
  }

  Widget? _section({required String title, required IconData icon, required List<Widget?> children}) {
    final visible = children.whereType<Widget>().toList();
    if (visible.isEmpty) return null;
    return _Section(title: title, icon: icon, children: visible);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final isFree = ref.watch(subscriptionProvider).tier == SubscriptionTier.free;

    // FIX: Use untyped list literal so Widget? returns from _section() are accepted.
    // .whereType<Widget>() at the end filters out nulls.
    final sections = [
      // ─── ACCOUNT ───
      if (_query.isEmpty) _AccountCard(authState: auth, isFree: isFree),

      // ─── APPEARANCE ───
      _section(title: l10n.settingsAppearance, icon: Icons.palette_outlined, children: [
        _m(l10n.settingsTheme) ? _ThemeSelectionTile(
          currentTheme: s.appTheme,
          onThemeSelected: (t) => ref.read(settingsProvider.notifier).setAppTheme(t),
        ) : null,
        _m(l10n.settingsThemeMode) ? _ThemeModeTile(
          currentMode: s.themeMode,
          onModeSelected: (m) => ref.read(settingsProvider.notifier).setThemeMode(m),
        ) : null,
        _m(l10n.settingsLanguage) ? _LanguageTile(
          currentLanguage: s.languageCode,
          onLanguageSelected: (c) => ref.read(settingsProvider.notifier).setLanguage(c),
        ) : null,
        _m(l10n.textSize, 'accessibility font') ? _TextScaleTile(
          currentScale: s.textScaleFactor,
          onScaleChanged: (v) => ref.read(settingsProvider.notifier).setTextScaleFactor(v),
        ) : null,
        _m(l10n.nutritionDisplay) ? _Tile(
          icon: Icons.tune, title: l10n.nutritionDisplay, subtitle: l10n.nutritionDisplaySubtitle,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NutritionSettingsScreen())),
        ) : null,
        _m(l10n.settingsWeekStartDay) ? _WeekStartDayTile(
          currentDay: s.weekStartDay,
          onDaySelected: (d) => ref.read(settingsProvider.notifier).setWeekStartDay(d),
        ) : null,
        _m(l10n.settingsSurpriseMe, 'surprise recipe suggestion') ? SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          secondary: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.auto_fix_high, size: 20, color: theme.colorScheme.primary),
          ),
          title: Text(l10n.settingsSurpriseMe, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          subtitle: Text(l10n.settingsSurpriseMeSubtitle, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
          value: s.showSurpriseMe,
          onChanged: (v) => ref.read(settingsProvider.notifier).setShowSurpriseMe(v),
        ) : null,
      ]),

      // ─── RECIPES ───
      _section(title: l10n.settingsRecipes, icon: Icons.menu_book_outlined, children: [
        _m(l10n.settingsQuickAccess) ? _Tile(
          icon: Icons.bolt, title: l10n.settingsQuickAccess, subtitle: l10n.settingsQuickAccessSubtitle,
          onTap: () => context.push('/settings/quick-access'),
        ) : null,
        _m(l10n.settingsRecipeLayout) ? _Tile(
          icon: Icons.view_agenda, title: l10n.settingsRecipeLayout,
          subtitle: s.recipeLayoutMode == RecipeLayoutMode.tabbed ? l10n.layoutTabbed : l10n.layoutStacked,
          onTap: () => context.push('/settings/recipe-layout'),
        ) : null,
        _m(l10n.settingsIngredientLayout) ? _Tile(
          icon: Icons.format_align_left, title: l10n.settingsIngredientLayout,
          subtitle: s.ingredientLayout == IngredientLayout.columnar ? l10n.ingredientLayoutColumnar : l10n.ingredientLayoutInline,
          onTap: () => context.push('/settings/ingredient-layout'),
        ) : null,
        _m(l10n.settingsMeasurements, 'metric imperial') ? _MeasurementSystemTile(
          currentSystem: s.measurementSystem,
          onSystemSelected: (v) => ref.read(settingsProvider.notifier).setMeasurementSystem(v),
        ) : null,
        _m(l10n.settingsAllergies, 'allergy') ? _Tile(
          icon: Icons.warning_amber,
          title: l10n.settingsAllergies,
          subtitle: l10n.settingsAllergiesSubtitle,
          onTap: () => context.push('/settings/allergies'),
        ) : null,
      ]),

      // ─── SHOPPING & PLANNING ───
      _section(title: l10n.settingsShoppingPlanning, icon: Icons.shopping_cart_outlined, children: [
        _m(l10n.myPantry, 'always on hand') ? _Tile(
          icon: Icons.kitchen, title: l10n.myPantry, subtitle: l10n.itemsAlwaysOnHand,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PantryScreen())),
        ) : null,
        _m(l10n.settingsShoppingCategories) ? _Tile(
          icon: Icons.view_list, title: l10n.settingsShoppingCategories, subtitle: l10n.settingsShoppingCategoriesSubtitle,
          onTap: () => context.push('/settings/shopping-categories'),
        ) : null,
        _m(l10n.trashTitle, 'deleted') ? _Tile(
          icon: Icons.delete_outline, title: l10n.trashTitle, subtitle: l10n.trashSubtitle,
          onTap: () => context.push('/settings/trash'),
        ) : null,
      ]),

      // ─── NOTIFICATIONS ───
      _section(title: l10n.settingsNotifications, icon: Icons.notifications_outlined, children: [
        _Tile(
          icon: Icons.notifications_outlined,
          title: l10n.settingsNotifications,
          subtitle: l10n.settingsNotifManagePreferences,
          onTap: () => context.push('/settings/notifications'),
        ),
      ]),

      // ─── MANAGE ───
      _section(title: l10n.settingsManage, icon: Icons.tune, children: [
        _m(l10n.settingsManageTags, 'tag label') ? _Tile(
          icon: Icons.local_offer_outlined, title: l10n.settingsManageTags, subtitle: l10n.settingsManageTagsSubtitle,
          onTap: () => context.push('/settings/tags'),
        ) : null,
        _m(l10n.settingsManageCourses, 'course meal') ? _Tile(
          icon: Icons.restaurant_menu, title: l10n.settingsManageCourses, subtitle: l10n.settingsManageCoursesSubtitle,
          onTap: () => context.push('/settings/courses'),
        ) : null,
        _m(l10n.settingsManageCategories, 'category') ? _Tile(
          icon: Icons.category_outlined, title: l10n.settingsManageCategories, subtitle: l10n.settingsManageCategoriesSubtitle,
          onTap: () => context.push('/settings/categories'),
        ) : null,
      ]),

      // ─── FAMILY ───
      if (_query.isEmpty || _m(l10n.settingsFamily, 'sharing invite members household'))
        _section(title: l10n.settingsFamily, icon: Icons.family_restroom, children: [
          _m(l10n.familySharing, 'invite share cookbook list') ? _Tile(
            icon: Icons.family_restroom, title: l10n.familySharing,
            subtitle: FamilyService.instance.isInFamily
                ? l10n.familyManage
                : l10n.familySharingSubtitle,
            onTap: () => context.push('/settings/family'),
          ) : null,
        ]),

      // ─── DATA ───
      _section(title: l10n.settingsData, icon: Icons.storage_outlined, children: [
        _m(l10n.settingsExport, 'backup') ? _Tile(
          icon: Icons.file_upload_outlined, title: l10n.settingsExport, subtitle: l10n.settingsExportSubtitle,
          onTap: () => _showExportOptions(context, ref),
        ) : null,
        _m(l10n.settingsImport, 'restore') ? _Tile(
          icon: Icons.file_download_outlined, title: l10n.settingsImport, subtitle: l10n.settingsImportSubtitle,
          onTap: () => _showImportOptions(context, ref),
        ) : null,
        _m(l10n.settingsRestoreDefaults, 'starter recipes default') ? _Tile(
          icon: Icons.auto_fix_high_rounded, title: l10n.settingsRestoreDefaults, subtitle: l10n.settingsRestoreDefaultsSubtitle,
          onTap: () => _restoreDefaultRecipes(context, ref),
        ) : null,
        _m(l10n.settingsDeleteData, 'erase reset') ? _Tile(
          icon: Icons.delete_forever_outlined, title: l10n.settingsDeleteData, subtitle: l10n.settingsDeleteDataSubtitle,
          titleColor: theme.colorScheme.error,
          onTap: () => _showResetConfirmation(context, ref),
        ) : null,
      ]),

      // TODO: Kitchen Buddy — hidden for now. Finish if app grows and community wants it.
      // See lib/ui/screens/kitchen_buddy/, lib/ui/widgets/kitchen_buddy/

      // ─── ABOUT ───
      if (_query.isEmpty || _m(l10n.appTitle, 'version about'))
        _Section(title: l10n.settingsAbout, icon: Icons.info_outline, children: [
          _Tile(
            icon: Icons.info_outline, title: l10n.appTitle,
            subtitle: l10n.settingsVersion(ref.watch(appVersionProvider).valueOrNull ?? '...'),
            onTap: () => context.push('/about'),
          ),
        ]),
    ].whereType<Widget>().toList();

    return Scaffold(
      body: Responsive.constrainWidth(context, child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true, snap: true,
            title: Text(l10n.settingsTitle),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _SearchField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (q) => setState(() => _query = q.trim()),
                ),
              ),
            ),
          ),
          if (sections.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off, size: 48, color: theme.colorScheme.outline),
                    const SizedBox(height: 12),
                    Text(l10n.settingsNoMatchingSettings,
                        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline)),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, i) => i == sections.length ? const SizedBox(height: 40) : sections[i],
                childCount: sections.length + 1,
              ),
            ),
        ],
      )),
    );
  }

  // ─── DATA DIALOGS ───

  void _showExportOptions(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.read(databaseProvider);
    final service = ExportImportService(db);
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (context) => _ExportOptionsSheet(
      l10n: l10n,
      onExportCookbook: () async {
        Navigator.pop(context);
        AppSnackbar.loading(context, l10n.exporting);
        final cookbookId = ref.read(selectedCookbookIdProvider) ?? 'starter';
        final data = await service.exportCookbook(cookbookId);
        await service.shareExport(data, 'cookbook_export.json');
        if (context.mounted) AppSnackbar.dismiss(context);
      },
      onExportSelective: (options) async {
        Navigator.pop(context);
        AppSnackbar.loading(context, l10n.exporting);
        final data = await service.exportSelective(options);
        await service.shareExport(data, 'recipe_spellbook_backup.json');
        if (context.mounted) AppSnackbar.dismiss(context);
      },
    ));
  }

  void _showImportOptions(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.read(databaseProvider);
    final service = ExportImportService(db);
    showModalBottomSheet(context: context, builder: (context) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(padding: const EdgeInsets.all(16), child: Text(l10n.settingsImport, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        ListTile(
          leading: const Icon(Icons.file_open), title: Text(l10n.importFromJson), subtitle: Text(l10n.importFromJsonSubtitle),
          onTap: () async {
            Navigator.pop(context);
            AppSnackbar.loading(context, l10n.importing);
            final result = await service.importFromFile();
            if (context.mounted) {
              AppSnackbar.dismiss(context);
              result.success ? AppSnackbar.success(context, result.message) : AppSnackbar.error(context, result.message);
            }
          },
        ),
        const SizedBox(height: 16),
      ]),
    ));
  }

  Future<void> _restoreDefaultRecipes(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsRestoreDefaults),
        content: Text(l10n.settingsRestoreDefaultsConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.actionAdd),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      final db = ref.read(databaseProvider);
      final count = await OnboardingService.seedDefaultRecipes(db);
      if (context.mounted) {
        AppSnackbar.success(context, l10n.starterRecipesAdded(count));
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.error(context, l10n.somethingWentWrong(e.toString()));
      }
    }
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    showDialog(context: context, builder: (context) => AlertDialog(
      icon: Icon(Icons.warning_amber_rounded, size: 48, color: theme.colorScheme.error),
      title: Text(l10n.resetApp),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.resetAppWarning), const SizedBox(height: 20),
        Text(l10n.whatToDelete, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _ResetOptionTile(icon: Icons.phone_android, title: l10n.localData, subtitle: l10n.localDataDesc, color: theme.colorScheme.error, onTap: () { Navigator.pop(context); _showLocalResetConfirmation(context, ref); }),
        const SizedBox(height: 8),
        _ResetOptionTile(icon: Icons.delete_forever, title: l10n.allData, subtitle: l10n.allDataDesc, color: theme.colorScheme.error, onTap: () { Navigator.pop(context); _showAllDataWarning(context, ref); }),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.actionCancel))],
    ));
  }

  /// Local data deletion.
  /// - With cloud sync: simple type-DELETE (data recoverable from cloud).
  /// - Without cloud sync (free tier): double-checkbox warning first,
  ///   because this is ALL their data with no way to get it back.
  void _showLocalResetConfirmation(BuildContext context, WidgetRef ref) {
    final hasCloud = ref.read(subscriptionProvider).hasCloudSync;
    if (hasCloud) {
      _showTypeDeleteConfirmation(context, ref, _ResetScope.local);
    } else {
      _showLocalNoCloudWarning(context, ref);
    }
  }

  /// Free-tier local delete — SCREEN 1: Checkbox acknowledgments.
  /// Without cloud sync this deletes everything with no recovery.
  void _showLocalNoCloudWarning(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final check1 = ValueNotifier(false);
    final check2 = ValueNotifier(false);
    showDialog<void>(context: context, builder: (context) {
      final theme = Theme.of(context);
      final errorColor = theme.colorScheme.error;
      return AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, size: 48, color: errorColor),
        title: Text(l10n.allDataWarningTitle),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _DeleteBullet(icon: Icons.phone_android, text: l10n.allDataWarningLocalData),
          const SizedBox(height: 6),
          _DeleteBullet(icon: Icons.settings, text: l10n.allDataWarningSettings),
          const SizedBox(height: 6),
          _DeleteBullet(icon: Icons.cloud_off, text: l10n.localNoCloudWarning),
          const SizedBox(height: 20),
          ValueListenableBuilder<bool>(valueListenable: check1, builder: (_, v, __) =>
            CheckboxListTile(
              value: v, onChanged: (val) => check1.value = val ?? false,
              title: Text(l10n.allDataIUnderstand, style: theme.textTheme.bodySmall),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true, contentPadding: EdgeInsets.zero,
              activeColor: errorColor,
            ),
          ),
          ValueListenableBuilder<bool>(valueListenable: check2, builder: (_, v, __) =>
            CheckboxListTile(
              value: v, onChanged: (val) => check2.value = val ?? false,
              title: Text(l10n.allDataNoUndo, style: theme.textTheme.bodySmall),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true, contentPadding: EdgeInsets.zero,
              activeColor: errorColor,
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.actionCancel)),
          ListenableBuilder(listenable: Listenable.merge([check1, check2]), builder: (context, _) {
            final ok = check1.value && check2.value;
            return FilledButton(
              style: FilledButton.styleFrom(backgroundColor: errorColor),
              onPressed: ok ? () { Navigator.pop(context); _showTypeDeleteConfirmation(context, ref, _ResetScope.local); } : null,
              child: Text(l10n.actionContinue),
            );
          }),
        ],
      );
    }).then((_) { check1.dispose(); check2.dispose(); });
  }

  /// Simple type-DELETE confirmation screen (used by both local+cloud and all-data flows).
  void _showTypeDeleteConfirmation(BuildContext context, WidgetRef ref, _ResetScope scope) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final scopeLabel = switch (scope) { _ResetScope.local => l10n.resetScopeLocal, _ResetScope.all => l10n.resetScopeAll };
    showDialog<void>(context: context, builder: (context) => AlertDialog(
      icon: Icon(Icons.delete_forever, size: 48, color: Theme.of(context).colorScheme.error),
      title: Text(l10n.finalConfirmation),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(l10n.permanentlyDeleteWarning(scopeLabel)), const SizedBox(height: 16),
        Text(l10n.typeDeleteToConfirm, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 16),
        TextField(controller: controller, decoration: InputDecoration(hintText: l10n.typeDeleteHint, border: const OutlineInputBorder()), textCapitalization: TextCapitalization.characters, autofocus: true),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.actionCancel)),
        ListenableBuilder(listenable: controller, builder: (context, _) {
          final ok = controller.text.toUpperCase() == l10n.typeDeleteHint.toUpperCase();
          return FilledButton(style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error), onPressed: ok ? () => _performReset(context, ref, l10n, scope) : null, child: Text(l10n.actionDelete));
        }),
      ],
    )).then((_) => controller.dispose());
  }

  /// All data — SCREEN 1: Checkbox acknowledgments showing exactly what will be deleted.
  void _showAllDataWarning(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final check1 = ValueNotifier(false);
    final check2 = ValueNotifier(false);
    showDialog<void>(context: context, builder: (context) {
      final theme = Theme.of(context);
      final errorColor = theme.colorScheme.error;
      return AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, size: 48, color: errorColor),
        title: Text(l10n.allDataWarningTitle),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          // What will be deleted
          _DeleteBullet(icon: Icons.cloud_off, text: l10n.allDataWarningCloudData),
          const SizedBox(height: 6),
          _DeleteBullet(icon: Icons.phone_android, text: l10n.allDataWarningLocalData),
          const SizedBox(height: 6),
          _DeleteBullet(icon: Icons.person_off, text: l10n.allDataWarningAccount),
          const SizedBox(height: 6),
          _DeleteBullet(icon: Icons.settings, text: l10n.allDataWarningSettings),
          const SizedBox(height: 20),
          // Checkbox acknowledgments
          ValueListenableBuilder<bool>(valueListenable: check1, builder: (_, v, __) =>
            CheckboxListTile(
              value: v, onChanged: (val) => check1.value = val ?? false,
              title: Text(l10n.allDataIUnderstand, style: theme.textTheme.bodySmall),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true, contentPadding: EdgeInsets.zero,
              activeColor: errorColor,
            ),
          ),
          ValueListenableBuilder<bool>(valueListenable: check2, builder: (_, v, __) =>
            CheckboxListTile(
              value: v, onChanged: (val) => check2.value = val ?? false,
              title: Text(l10n.allDataNoUndo, style: theme.textTheme.bodySmall),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true, contentPadding: EdgeInsets.zero,
              activeColor: errorColor,
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.actionCancel)),
          ListenableBuilder(listenable: Listenable.merge([check1, check2]), builder: (context, _) {
            final ok = check1.value && check2.value;
            return FilledButton(
              style: FilledButton.styleFrom(backgroundColor: errorColor),
              onPressed: ok ? () { Navigator.pop(context); _showTypeDeleteConfirmation(context, ref, _ResetScope.all); } : null,
              child: Text(l10n.actionContinue),
            );
          }),
        ],
      );
    }).then((_) { check1.dispose(); check2.dispose(); });
  }

  Future<void> _performReset(BuildContext context, WidgetRef ref, AppLocalizations l10n, _ResetScope scope) async {
    // Capture references before navigating away (widget will unmount)
    final db = ref.read(databaseProvider);
    final settingsNotifier = scope == _ResetScope.all
        ? ref.read(settingsProvider.notifier)
        : null;

    // Pop the confirmation dialog
    if (context.mounted) Navigator.pop(context);

    // Navigate to splash FIRST — this tears down all data-watching widgets
    // and prevents framework assertion errors from provider-driven rebuilds
    // against empty data.
    if (context.mounted) context.go('/splash');

    // Wait for navigation and widget tree teardown to complete
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      // Use proper Drift transaction methods — atomic, triggers stream
      // notifications so providers update correctly, and re-seeds defaults.
      if (scope == _ResetScope.all) {
        // Delete account from server (cascades to all synced data).
        // Subscription is tied to Apple/Google via RevenueCat, not our
        // user row — it auto-restores on next sign-in.
        await AuthService.instance.deleteAccount();
        // Wipe local data
        await db.deleteAllUserData();
        settingsNotifier?.resetToDefaults();
      } else {
        // Local only: delete recipes/cookbooks/planner, keep shopping list
        await db.deleteLocalRecipeData();
        // Clear sync timestamp so next sync re-pulls from cloud
        await SyncService.instance.clearLastSyncAt();
      }

      // Reset onboarding so the intro flow triggers again —
      // the onboarding will offer to import default recipes automatically.
      await OnboardingService.resetOnboarding();
      HomeScreen.resetOnboardingCheck();
    } catch (e) {
      debugPrint('Reset error: $e');
    }
  }

}

// ════════════════════════════════════════════
//  SEARCH FIELD
// ════════════════════════════════════════════

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.controller, required this.focusNode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller, focusNode: focusNode, onChanged: onChanged,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.settingsSearchHint,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
        prefixIcon: Icon(Icons.search, size: 20, color: theme.colorScheme.outline),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(icon: Icon(Icons.close, size: 18, color: theme.colorScheme.outline), onPressed: () { controller.clear(); onChanged(''); focusNode.unfocus(); })
            : null,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5)),
      ),
    );
  }
}

// ════════════════════════════════════════════
//  ACCOUNT CARD
// ════════════════════════════════════════════

class _AccountCard extends ConsumerWidget {
  final AuthState authState;
  final bool isFree;
  const _AccountCard({required this.authState, required this.isFree});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isIn = authState.isSignedIn;
    final user = authState.user;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: InkWell(
          onTap: () => context.push('/settings/account'),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primary.withValues(alpha: 0.15)),
                child: isIn && user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                    ? ClipOval(child: Image.network(user.avatarUrl!, width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _avatar(theme, user.displayName)))
                    : _avatar(theme, user?.displayName),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: Text(isIn ? (user?.displayName ?? l10n.settingsUserFallback) : l10n.signIn, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  const _TierBadge(),
                ]),
                const SizedBox(height: 2),
                Text(isIn ? (user?.email ?? '') : l10n.signInDescription, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline), maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
              Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.outline),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _avatar(ThemeData theme, String? name) {
    return Center(child: Text((name != null && name.isNotEmpty) ? name[0].toUpperCase() : '?',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)));
  }
}

class _TierBadge extends ConsumerWidget {
  const _TierBadge();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tier = ref.watch(subscriptionProvider).tier;
    final (label, color) = switch (tier) {
      SubscriptionTier.free => (l10n.tierFree, Theme.of(context).colorScheme.outline),
      SubscriptionTier.premium => (l10n.tierPremium, Colors.amber.shade700),
      SubscriptionTier.cloudSync => (l10n.tierCloudSync, Colors.blue),
      SubscriptionTier.cloudSyncFamily => (l10n.tierFamily, Colors.deepPurple),
      SubscriptionTier.creator => (l10n.tierCreator, Colors.deepPurple),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: color)),
    );
  }
}

// ════════════════════════════════════════════
//  CORE WIDGETS
// ════════════════════════════════════════════

enum _ResetScope { local, all }

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _Section({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? theme.colorScheme.surfaceContainerHigh : theme.colorScheme.surfaceContainerLowest;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Row(children: [
          Icon(icon, size: 14, color: theme.colorScheme.outline),
          const SizedBox(width: 6),
          Text(title.toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
        ]),
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: isDark ? 0.3 : 0.5), width: 0.5)),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) Divider(height: 0.5, thickness: 0.5, indent: 56, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
          ],
        ]),
      ),
    ]);
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? titleColor;
  final bool enabled;
  const _Tile({required this.icon, required this.title, required this.subtitle, required this.onTap, this.titleColor, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = enabled ? (titleColor ?? theme.colorScheme.primary) : theme.colorScheme.outline;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: c)),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: enabled ? titleColor : theme.colorScheme.outline)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 13, color: enabled ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.outline)),
      trailing: enabled ? Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.5)) : null,
      onTap: enabled ? onTap : null,
    );
  }
}

class _ResetOptionTile extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final Color color; final bool enabled; final VoidCallback onTap;
  const _ResetOptionTile({required this.icon, required this.title, required this.subtitle, required this.color, this.enabled = true, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(color: Colors.transparent, child: InkWell(onTap: enabled ? onTap : null, borderRadius: BorderRadius.circular(12),
      child: Opacity(opacity: enabled ? 1.0 : 0.4, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(border: Border.all(color: color.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, color: color, size: 24), const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: color)),
            Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ])),
          if (enabled) Icon(Icons.chevron_right, color: color, size: 20),
        ]),
      )),
    ));
  }
}

class _DeleteBullet extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DeleteBullet({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(children: [
      Icon(icon, size: 18, color: theme.colorScheme.error),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
    ]);
  }
}

// ════════════════════════════════════════════
//  TEXT SCALE TILE
// ════════════════════════════════════════════

class _TextScaleTile extends StatelessWidget {
  final double currentScale;
  final ValueChanged<double> onScaleChanged;
  const _TextScaleTile({required this.currentScale, required this.onScaleChanged});

  String _label(AppLocalizations l10n) {
    if (currentScale <= 0.85) return l10n.textSizeSmall;
    if (currentScale <= 0.95) return l10n.textSizeDefault;
    if (currentScale <= 1.05) return l10n.textSizeMedium;
    if (currentScale <= 1.15) return l10n.textSizeLarge;
    return l10n.textSizeExtraLarge;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.text_fields_rounded, size: 20, color: theme.colorScheme.primary)),
      title: Text(l10n.textSize, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text(_label(l10n), style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
      trailing: Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      onTap: () => _showPicker(context),
    );
  }

  void _showPicker(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    double temp = currentScale;
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx) => StatefulBuilder(
      builder: (ctx, ss) => SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text(l10n.textSize, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(l10n.settingsTextSizeSubtitle, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.textSizePreview, style: TextStyle(fontSize: 12 * temp, color: theme.colorScheme.outline)),
              const SizedBox(height: 4),
              Text('Grandma\'s Famous Chocolate Cake', style: TextStyle(fontSize: 16 * temp, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text('2 cups flour, 1 cup sugar, 3 eggs', style: TextStyle(fontSize: 14 * temp, color: theme.colorScheme.onSurfaceVariant)),
            ]),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Text('A', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.outline)),
            Expanded(child: Slider(value: temp, min: 0.8, max: 1.3, divisions: 5, label: '${(temp * 100).round()}%', onChanged: (v) { ss(() => temp = v); onScaleChanged(v); })),
            Text('A', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.outline)),
          ]),
          const SizedBox(height: 4),
          Text('${(temp * 100).round()}%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
          const SizedBox(height: 16),
        ]),
      )),
    ));
  }
}

// ════════════════════════════════════════════
//  THEME SELECTION TILE + CARD
// ════════════════════════════════════════════

class _ThemeSelectionTile extends ConsumerWidget {
  final AppColorTheme currentTheme;
  final ValueChanged<AppColorTheme> onThemeSelected;
  const _ThemeSelectionTile({required this.currentTheme, required this.onThemeSelected});

  String _name(BuildContext context, AppColorTheme t) {
    final l = AppLocalizations.of(context)!;
    return switch (t) {
      AppColorTheme.spellbook => l.themeSpellbook,
      AppColorTheme.custom => l.themeCustom,
      AppColorTheme.forest => l.themeForest,
      AppColorTheme.ocean => l.themeOcean,
      AppColorTheme.sunset => l.themeSunset,
      AppColorTheme.midnight => l.themeMidnight,
      AppColorTheme.rose => l.themeRose,
      AppColorTheme.frost => l.themeFrost,
      AppColorTheme.ember => l.themeEmber,
      AppColorTheme.spring => l.themeSpring,
      AppColorTheme.alchemist => l.themeAlchemist,
      AppColorTheme.matcha => l.themeMatcha,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.palette_outlined, size: 20, color: theme.colorScheme.primary)),
      title: Text(l10n.settingsTheme, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text('${currentTheme.emoji} ${_name(context, currentTheme)}', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
      trailing: Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      onTap: () => _showPicker(context, ref),
    );
  }

  void _showPicker(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tier = ref.read(subscriptionProvider).tier;
    final isPremium = tier.index >= SubscriptionTier.premium.index;
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (context) => DraggableScrollableSheet(
      expand: false, initialChildSize: 0.7, maxChildSize: 0.9, minChildSize: 0.4,
      builder: (context, sc) => SafeArea(child: Column(children: [
        const SizedBox(height: 8),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
        Padding(padding: const EdgeInsets.all(16), child: Text(l10n.settingsTheme, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        Expanded(child: GridView.builder(
          controller: sc, padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.5, crossAxisSpacing: 12, mainAxisSpacing: 12),
          itemCount: AppColorTheme.values.length,
          itemBuilder: (context, i) {
            final t = AppColorTheme.values[i];
            return _ThemeCard(
              theme: t,
              label: _name(context, t),
              isSelected: currentTheme == t,
              isPremiumLocked: t.isCustom && !isPremium,
              onTap: () {
                if (t.isCustom && !isPremium) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.appearanceCustomThemeRequiresPremium)),
                  );
                } else if (t.isCustom) {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomThemeScreen()));
                } else {
                  onThemeSelected(t);
                  Navigator.pop(context);
                }
              },
            );
          },
        )),
        const SizedBox(height: 16),
      ])),
    ));
  }
}


class _ThemeCard extends StatelessWidget {
  final AppColorTheme theme; final String label; final bool isSelected; final bool isPremiumLocked; final VoidCallback onTap;
  const _ThemeCard({required this.theme, required this.label, required this.isSelected, required this.onTap, this.isPremiumLocked = false});

  @override
  Widget build(BuildContext context) {
    final ui = Theme.of(context);
    return GestureDetector(onTap: onTap, child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isSelected ? ui.colorScheme.primary : Colors.transparent, width: isSelected ? 3 : 0),
        boxShadow: isSelected ? [BoxShadow(color: ui.colorScheme.primary.withValues(alpha: 0.3), blurRadius: 8)] : [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(isSelected ? 11 : 14), child: Stack(fit: StackFit.expand, children: [
        Image.asset(theme.bannerAsset, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: theme.seedColor.withValues(alpha: 0.3))),
        // Premium lock badge
        if (isPremiumLocked)
          Positioned(top: 8, left: 8, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.lock_rounded, color: Colors.amber, size: 12),
              const SizedBox(width: 2),
              Text(AppLocalizations.of(context)!.appearancePremiumBadge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
            ]),
          )),
        Positioned(left: 0, right: 0, bottom: 0, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withValues(alpha: 0.0), Colors.black.withValues(alpha: 0.65)])),
          child: Row(children: [
            Text(theme.emoji, style: const TextStyle(fontSize: 14)), const SizedBox(width: 4),
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, shadows: [Shadow(blurRadius: 4, color: Colors.black)]), overflow: TextOverflow.ellipsis)),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.white, size: 18),
          ]),
        )),
      ])),
    ));
  }
}

// ════════════════════════════════════════════
//  THEME MODE TILE
// ════════════════════════════════════════════

class _ThemeModeTile extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onModeSelected;
  const _ThemeModeTile({required this.currentMode, required this.onModeSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final (subtitle, icon) = switch (currentMode) {
      ThemeMode.system => (l10n.settingsThemeModeSystem, Icons.brightness_auto),
      ThemeMode.light => (l10n.settingsThemeModeLight, Icons.light_mode),
      ThemeMode.dark => (l10n.settingsThemeModeDark, Icons.dark_mode),
    };
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: theme.colorScheme.primary)),
      title: Text(l10n.settingsThemeMode, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
      trailing: Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      onTap: () {
        showModalBottomSheet(context: context, builder: (context) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(padding: const EdgeInsets.all(16), child: Text(l10n.settingsThemeMode, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          for (final m in ThemeMode.values)
            ListTile(
              leading: Icon(switch (m) { ThemeMode.system => Icons.brightness_auto, ThemeMode.light => Icons.light_mode, ThemeMode.dark => Icons.dark_mode }),
              title: Text(switch (m) { ThemeMode.system => l10n.settingsThemeModeSystem, ThemeMode.light => l10n.settingsThemeModeLight, ThemeMode.dark => l10n.settingsThemeModeDark }),
              trailing: currentMode == m ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
              onTap: () { onModeSelected(m); Navigator.pop(context); },
            ),
          const SizedBox(height: 16),
        ])));
      },
    );
  }
}

// ════════════════════════════════════════════
//  MEASUREMENT SYSTEM TILE
// ════════════════════════════════════════════

class _MeasurementSystemTile extends StatelessWidget {
  final MeasurementSystem currentSystem;
  final ValueChanged<MeasurementSystem> onSystemSelected;
  const _MeasurementSystemTile({required this.currentSystem, required this.onSystemSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.straighten, size: 20, color: theme.colorScheme.primary)),
      title: Text(l10n.settingsMeasurements, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text(currentSystem.displayName, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
      trailing: Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      onTap: () {
        showModalBottomSheet(context: context, builder: (context) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(padding: const EdgeInsets.all(16), child: Text(l10n.settingsMeasurements, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ListTile(leading: const Text('\u{1F1FA}\u{1F1F8}', style: TextStyle(fontSize: 24)), title: Text(l10n.settingsMeasurementsUS), subtitle: Text(l10n.usUnits), trailing: currentSystem == MeasurementSystem.us ? Icon(Icons.check, color: theme.colorScheme.primary) : null, onTap: () { onSystemSelected(MeasurementSystem.us); Navigator.pop(context); }),
          ListTile(leading: const Text('\u{1F30D}', style: TextStyle(fontSize: 24)), title: Text(l10n.settingsMeasurementsMetric), subtitle: Text(l10n.metricUnits), trailing: currentSystem == MeasurementSystem.metric ? Icon(Icons.check, color: theme.colorScheme.primary) : null, onTap: () { onSystemSelected(MeasurementSystem.metric); Navigator.pop(context); }),
          const SizedBox(height: 16),
        ])));
      },
    );
  }
}

// ════════════════════════════════════════════
//  WEEK START DAY TILE
// ════════════════════════════════════════════

class _WeekStartDayTile extends StatelessWidget {
  final int currentDay;
  final ValueChanged<int> onDaySelected;
  const _WeekStartDayTile({required this.currentDay, required this.onDaySelected});

  String _name(BuildContext context, int d) {
    final l = AppLocalizations.of(context)!;
    return switch (d) { 1 => l.monday, 2 => l.tuesday, 3 => l.wednesday, 4 => l.thursday, 5 => l.friday, 6 => l.saturday, 7 => l.sunday, _ => l.monday };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.calendar_today, size: 20, color: theme.colorScheme.primary)),
      title: Text(l10n.settingsWeekStartDay, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text(_name(context, currentDay), style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
      trailing: Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      onTap: () {
        showModalBottomSheet(context: context, builder: (context) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(padding: const EdgeInsets.all(16), child: Text(l10n.settingsWeekStartDay, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          for (final d in [1,2,3,4,5,6,7])
            ListTile(title: Text(_name(context, d)), trailing: currentDay == d ? Icon(Icons.check, color: theme.colorScheme.primary) : null, onTap: () { onDaySelected(d); Navigator.pop(context); }),
          const SizedBox(height: 16),
        ])));
      },
    );
  }
}

// ════════════════════════════════════════════
//  LANGUAGE TILE
// ════════════════════════════════════════════

class _LanguageTile extends StatelessWidget {
  final String currentLanguage;
  final ValueChanged<String> onLanguageSelected;
  const _LanguageTile({required this.currentLanguage, required this.onLanguageSelected});

  String? get _currentName {
    for (final lang in supportedLanguages) {
      if (lang.code == currentLanguage) return '${lang.flag} ${lang.nativeName}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.language, size: 20, color: theme.colorScheme.primary)),
      title: Text(l10n.settingsLanguage, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text(_currentName ?? '\u{1F310} ${l10n.settingsSystemLanguage}', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
      trailing: Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      onTap: () {
        showModalBottomSheet(context: context, isScrollControlled: true, builder: (context) => DraggableScrollableSheet(
          expand: false, initialChildSize: 0.6, maxChildSize: 0.85, minChildSize: 0.3,
          builder: (context, sc) => SafeArea(child: Column(children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
            Padding(padding: const EdgeInsets.all(16), child: Text(l10n.settingsLanguage, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            Expanded(child: ListView(controller: sc, children: [
              ...supportedLanguages.map((lang) => ListTile(
                leading: Text(lang.flag, style: const TextStyle(fontSize: 24)),
                title: Text(lang.nativeName), subtitle: Text(lang.name),
                trailing: currentLanguage == lang.code ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                onTap: () { onLanguageSelected(lang.code); Navigator.pop(context); },
              )),
              const SizedBox(height: 16),
            ])),
          ])),
        ));
      },
    );
  }
}


// ════════════════════════════════════════════
//  ADVANCED SETTINGS SCREEN (route target)
// ════════════════════════════════════════════

class AdvancedSettingsScreen extends StatelessWidget {
  const AdvancedSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsAdvanced)),
      body: ListView(children: [
        _Section(title: l10n.settingsManageSection, icon: Icons.tune, children: [
          _Tile(icon: Icons.local_offer_outlined, title: l10n.settingsManageTags, subtitle: l10n.settingsManageTagsSubtitle, onTap: () => context.push('/settings/tags')),
          _Tile(icon: Icons.restaurant_menu, title: l10n.settingsManageCourses, subtitle: l10n.settingsManageCoursesSubtitle, onTap: () => context.push('/settings/courses')),
          _Tile(icon: Icons.category_outlined, title: l10n.settingsManageCategories, subtitle: l10n.settingsManageCategoriesSubtitle, onTap: () => context.push('/settings/categories')),
          _Tile(icon: Icons.view_list, title: l10n.settingsShoppingCategories, subtitle: l10n.settingsShoppingCategoriesSubtitle, onTap: () => context.push('/settings/shopping-categories')),
        ]),
        const SizedBox(height: 32),
      ]),
    );
  }
}

// ════════════════════════════════════════════
//  EXPORT OPTIONS SHEET
// ════════════════════════════════════════════

class _ExportOptionsSheet extends StatefulWidget {
  final AppLocalizations l10n;
  final VoidCallback onExportCookbook;
  final ValueChanged<ExportOptions> onExportSelective;
  const _ExportOptionsSheet({required this.l10n, required this.onExportCookbook, required this.onExportSelective});
  @override
  State<_ExportOptionsSheet> createState() => _ExportOptionsSheetState();
}

class _ExportOptionsSheetState extends State<_ExportOptionsSheet> {
  bool _cookbooks = true, _shoppingLists = true, _mealPlans = true;
  bool _tags = true, _customCategories = true, _customCourses = true;

  int get _checkedCount => [_cookbooks, _shoppingLists, _mealPlans, _tags, _customCategories, _customCourses].where((b) => b).length;
  bool get _allChecked => _checkedCount == 6;
  bool get _noneChecked => _checkedCount == 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = widget.l10n;
    final l10n = AppLocalizations.of(context)!;
    final buttonLabel = _allChecked ? l.exportFullBackup : _noneChecked ? l10n.settingsExportNone : l10n.settingsExportPartial;
    return SafeArea(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(l.settingsExport, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListTile(leading: const Icon(Icons.menu_book), title: Text(l.exportCurrentCookbook), trailing: const Icon(Icons.chevron_right), onTap: widget.onExportCookbook),
        const Divider(),
        Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(l.exportFullBackup, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600))),
        _Chk(title: l.exportCookbooksRecipes, value: _cookbooks, onChanged: (v) => setState(() => _cookbooks = v ?? true)),
        _Chk(title: l.exportShoppingLists, value: _shoppingLists, onChanged: (v) => setState(() => _shoppingLists = v ?? false)),
        _Chk(title: l.exportMealPlans, value: _mealPlans, onChanged: (v) => setState(() => _mealPlans = v ?? false)),
        _Chk(title: l.exportTags, value: _tags, onChanged: (v) => setState(() => _tags = v ?? false)),
        _Chk(title: l.exportCategories, value: _customCategories, onChanged: (v) => setState(() => _customCategories = v ?? false)),
        _Chk(title: l.exportCourses, value: _customCourses, onChanged: (v) => setState(() => _customCourses = v ?? false)),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: FilledButton.icon(
          onPressed: _noneChecked ? null : () => widget.onExportSelective(ExportOptions(cookbooks: _cookbooks, shoppingLists: _shoppingLists, mealPlans: _mealPlans, tags: _tags, customCategories: _customCategories, customCourses: _customCourses)),
          icon: const Icon(Icons.download), label: Text(buttonLabel),
        )),
        const SizedBox(height: 12),
      ]),
    ));
  }
}

class _Chk extends StatelessWidget {
  final String title; final bool value; final ValueChanged<bool?> onChanged;
  const _Chk({required this.title, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => CheckboxListTile(title: Text(title), value: value, onChanged: onChanged, dense: true, controlAffinity: ListTileControlAffinity.leading, contentPadding: EdgeInsets.zero);
}