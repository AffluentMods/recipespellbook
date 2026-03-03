import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import 'package:recipespellbook/ui/screens/settings/pantry_screen.dart';
import '../../../data/app_enums.dart';
import '../../../providers/cookbook_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/companion_provider.dart';

import '../../../providers/settings_provider.dart';
import '../../../providers/subscription_provider.dart';
import '../../../providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/auth_service.dart';
import 'dart:io' show Platform;
import '../../../services/export_import_service.dart';
import '../../../services/family_service.dart';
import '../../../services/grocery_service.dart';
import '../../../services/onboarding_service.dart';
import '../../../services/revenuecat_service.dart';
import '../../../services/sync_service.dart';
import '../../widgets/app_snackbar.dart';
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
        _m(l10n.settingsAllergies, 'weaknesses allergy') ? _Tile(
          icon: s.nerdMode ? Icons.flash_on : Icons.warning_amber,
          title: s.nerdMode ? 'Weaknesses' : l10n.settingsAllergies,
          subtitle: s.nerdMode ? 'Set your dietary vulnerabilities' : l10n.settingsAllergiesSubtitle,
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
          subtitle: 'Manage notification preferences',
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

      // ─── INTEGRATIONS ───
      if (_query.isEmpty || _m('Integrations', 'google apple discord instacart kroger sign in'))
        const _IntegrationsSection(),

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
        _m(l10n.settingsDeleteData, 'erase reset') ? _Tile(
          icon: Icons.delete_forever_outlined, title: l10n.settingsDeleteData, subtitle: l10n.settingsDeleteDataSubtitle,
          titleColor: theme.colorScheme.error,
          onTap: () => _showResetConfirmation(context, ref),
        ) : null,
      ]),

      // ─── RPG MODE ───
      if (_query.isEmpty || _m('RPG Mode', 'nerd rpg companion'))
        _Section(title: '\u2728 RPG Mode', icon: Icons.auto_awesome, children: [
          _RpgModeTile(isEnabled: s.nerdMode, onChanged: (v) {
            ref.read(settingsProvider.notifier).setNerdMode(v);
            // When enabling RPG for the first time, navigate to companion naming
            if (v && ref.read(companionDataProvider) == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.push('/rpg/companion-naming');
                }
              });
            }
          }),
        ]),

      // ─── ABOUT ───
      if (_query.isEmpty || _m(l10n.appTitle, 'version about'))
        _Section(title: l10n.settingsAbout, icon: Icons.info_outline, children: [
          _Tile(
            icon: Icons.info_outline, title: l10n.appTitle,
            subtitle: 'Version ${ref.watch(appVersionProvider).valueOrNull ?? '...'} \u00B7 Beta',
            onTap: () => context.push('/about'),
          ),
        ]),
    ].whereType<Widget>().toList();

    return Scaffold(
      body: CustomScrollView(
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
      ),
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
        _ResetOptionTile(icon: Icons.phone_android, title: l10n.localData, subtitle: l10n.localDataDesc, color: theme.colorScheme.error, onTap: () { Navigator.pop(context); _showFinalResetConfirmation(context, ref, _ResetScope.local); }),
        const SizedBox(height: 8),
        _ResetOptionTile(icon: Icons.cloud_outlined, title: l10n.cloudData, subtitle: l10n.cloudDataDesc, color: theme.colorScheme.outline, enabled: false, onTap: () {}),
        const SizedBox(height: 8),
        _ResetOptionTile(icon: Icons.delete_forever, title: l10n.allData, subtitle: l10n.allDataDesc, color: theme.colorScheme.error, onTap: () { Navigator.pop(context); _showFinalResetConfirmation(context, ref, _ResetScope.all); }),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.actionCancel))],
    ));
  }

  void _showFinalResetConfirmation(BuildContext context, WidgetRef ref, _ResetScope scope) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final scopeLabel = switch (scope) { _ResetScope.local => 'local data', _ResetScope.cloud => 'cloud data', _ResetScope.all => 'all data and settings' };
    showDialog(context: context, builder: (context) => AlertDialog(
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
          final ok = controller.text.toUpperCase() == 'DELETE';
          return FilledButton(style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error), onPressed: ok ? () => _performReset(context, ref, l10n, scope) : null, child: Text(l10n.actionDelete));
        }),
      ],
    ));
  }

  Future<void> _performReset(BuildContext context, WidgetRef ref, AppLocalizations l10n, _ResetScope scope) async {
    try {
      final db = ref.read(databaseProvider);
      for (final t in ['recipe_links', 'recipe_tags', 'ingredient_usda_mappings', 'user_ingredient_mappings', 'ingredients', 'steps', 'recipes']) {
        await db.customStatement('DELETE FROM $t');
      }
      await db.customStatement("DELETE FROM cookbooks WHERE id != 'starter'");
      await db.customStatement('DELETE FROM shopping_list_items');
      await db.customStatement("DELETE FROM shopping_lists WHERE id != 'list_default'");
      await db.customStatement('DELETE FROM meal_plans');
      await db.customStatement('DELETE FROM custom_courses');
      await db.customStatement('DELETE FROM custom_categories');
      if (scope == _ResetScope.all) ref.read(settingsProvider.notifier).resetToDefaults();
      if (context.mounted) { Navigator.pop(context); _showReimportDefaultsDialog(context, ref, l10n); }
    } catch (e) {
      if (context.mounted) { Navigator.pop(context); AppSnackbar.error(context, '${l10n.resetFailed}: $e'); }
    }
  }

  void _showReimportDefaultsDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(context: context, barrierDismissible: false, builder: (context) => AlertDialog(
      icon: const Icon(Icons.auto_awesome, size: 48, color: Colors.amber),
      title: Text(l10n.dataResetComplete),
      content: Text(l10n.resetDataClearedDesc),
      actions: [
        TextButton(onPressed: () { Navigator.pop(context); AppSnackbar.success(context, l10n.appResetSuccess); context.go('/'); }, child: Text(l10n.noThanks)),
        FilledButton(onPressed: () async {
          Navigator.pop(context);
          AppSnackbar.loading(context, l10n.importingDefaultRecipes);
          try {
            final count = await OnboardingService.seedDefaultRecipes(ref.read(databaseProvider));
            if (context.mounted) { AppSnackbar.dismiss(context); AppSnackbar.success(context, l10n.defaultRecipesImported(count)); context.go('/'); }
          } catch (e) {
            if (context.mounted) { AppSnackbar.dismiss(context); AppSnackbar.error(context, '${l10n.importFailed}: $e'); context.go('/'); }
          }
        }, child: Text(l10n.yesAddThem)),
      ],
    ));
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
        child: Column(children: [
          InkWell(
            onTap: isIn ? null : () => _showSignInSheet(context, ref),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                    Flexible(child: Text(isIn ? (user?.displayName ?? 'User') : l10n.signIn, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    const _TierBadge(),
                  ]),
                  const SizedBox(height: 2),
                  Text(isIn ? (user?.email ?? '') : l10n.signInDescription, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline), maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
                if (isIn)
                  IconButton(icon: Icon(Icons.logout, size: 20, color: theme.colorScheme.error), tooltip: l10n.signOut, onPressed: () => ref.read(authProvider.notifier).signOut())
                else
                  Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.outline),
              ]),
            ),
          ),
          if (isIn && !isFree) ...[
            Divider(height: 0.5, indent: 16, endIndent: 16, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
            _SyncRow(theme: theme),
          ],
          if (isFree) ...[
            Divider(height: 0.5, indent: 16, endIndent: 16, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
            InkWell(
              onTap: () => context.push('/upgrade'),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(children: [
                  Icon(Icons.star_rounded, size: 18, color: Colors.amber.shade700),
                  const SizedBox(width: 10),
                  Expanded(child: Text(l10n.upgradeToPro, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.amber.shade700))),
                  Text(l10n.settingsUpgradeSubtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.outline),
                ]),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _avatar(ThemeData theme, String? name) {
    return Center(child: Text((name != null && name.isNotEmpty) ? name[0].toUpperCase() : '?',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)));
  }

  static void _showSignInSheet(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.read(authProvider.notifier);
    showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Icon(Icons.account_circle_outlined, size: 48, color: theme.colorScheme.primary),
        const SizedBox(height: 12),
        Text(l10n.signIn, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(l10n.signInDescription, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, child: OutlinedButton(
          onPressed: () { Navigator.pop(ctx); auth.signInWithGoogle(); },
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: theme.colorScheme.outlineVariant), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            const SizedBox(width: 10),
            Text(l10n.continueWithGoogle, style: TextStyle(fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
          ]),
        )),
        if (Platform.isIOS || Platform.isMacOS) ...[
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: FilledButton(
            onPressed: () { Navigator.pop(ctx); auth.signInWithApple(); },
            style: FilledButton.styleFrom(backgroundColor: theme.brightness == Brightness.dark ? Colors.white : Colors.black, foregroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.apple, size: 20), const SizedBox(width: 10), Text(l10n.continueWithApple, style: const TextStyle(fontWeight: FontWeight.w500))]),
          )),
        ],
        const SizedBox(height: 16),
      ]),
    )));
  }
}

class _SyncRow extends StatefulWidget {
  final ThemeData theme;
  const _SyncRow({required this.theme});
  @override
  State<_SyncRow> createState() => _SyncRowState();
}

class _SyncRowState extends State<_SyncRow> {
  bool _syncing = false;

  Future<void> _doSync() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    final result = await SyncService.instance.sync();
    if (!mounted) return;
    setState(() => _syncing = false);
    final l10n = AppLocalizations.of(context)!;
    if (result.success) {
      AppSnackbar.success(context, l10n.syncSuccess(result.pushedCount, result.pulledCount));
    } else {
      AppSnackbar.error(context, result.error ?? l10n.syncFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return InkWell(
      onTap: _syncing ? null : _doSync,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Icon(Icons.cloud_sync_rounded, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(AppLocalizations.of(context)!.cloudSync, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
          if (_syncing)
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary))
          else
            Icon(Icons.sync, size: 18, color: theme.colorScheme.outline),
        ]),
      ),
    );
  }
}

class _TierBadge extends ConsumerWidget {
  const _TierBadge();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(subscriptionProvider).tier;
    final (label, color) = switch (tier) {
      SubscriptionTier.free => ('FREE', Theme.of(context).colorScheme.outline),
      SubscriptionTier.premium => ('PREMIUM', Colors.amber.shade700),
      SubscriptionTier.cloudSync => ('CLOUD SYNC', Colors.blue),
      SubscriptionTier.cloudSyncFamily => ('FAMILY', Colors.deepPurple),
      SubscriptionTier.creator => ('CREATOR', Colors.deepPurple),
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

enum _ResetScope { local, cloud, all }

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

class _ThemeSelectionTile extends StatelessWidget {
  final AppColorTheme currentTheme;
  final ValueChanged<AppColorTheme> onThemeSelected;
  const _ThemeSelectionTile({required this.currentTheme, required this.onThemeSelected});

  String _name(BuildContext context, AppColorTheme t) {
    final l = AppLocalizations.of(context)!;
    return switch (t) {
      AppColorTheme.spellbook => l.themeSpellbook,
      AppColorTheme.forest => l.themeForest,
      AppColorTheme.ocean => l.themeOcean,
      AppColorTheme.sunset => l.themeSunset,
      AppColorTheme.midnight => l.themeMidnight,
      AppColorTheme.rose => l.themeRose,
      AppColorTheme.frost => l.themeFrost,
      AppColorTheme.ember => l.themeEmber,
      AppColorTheme.spring => l.themeSpring,
      AppColorTheme.alchemist => l.themeAlchemist,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.palette_outlined, size: 20, color: theme.colorScheme.primary)),
      title: Text(l10n.settingsTheme, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text('${currentTheme.emoji} ${_name(context, currentTheme)}', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
      trailing: Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      onTap: () => _showPicker(context),
    );
  }

  void _showPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            return _ThemeCard(theme: t, label: _name(context, t), isSelected: currentTheme == t, onTap: () { onThemeSelected(t); Navigator.pop(context); });
          },
        )),
        const SizedBox(height: 16),
      ])),
    ));
  }
}

class _ThemeCard extends StatelessWidget {
  final AppColorTheme theme; final String label; final bool isSelected; final VoidCallback onTap;
  const _ThemeCard({required this.theme, required this.label, required this.isSelected, required this.onTap});

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

  String get _currentName {
    for (final lang in supportedLanguages) {
      if (lang.code == currentLanguage) return '${lang.flag} ${lang.nativeName}';
    }
    return '\u{1F310} System';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.language, size: 20, color: theme.colorScheme.primary)),
      title: Text(l10n.settingsLanguage, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text(_currentName, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
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
//  RPG MODE TILE WITH ANIMATION
// ════════════════════════════════════════════

class _RpgModeTile extends StatefulWidget {
  final bool isEnabled;
  final ValueChanged<bool> onChanged;
  const _RpgModeTile({required this.isEnabled, required this.onChanged});
  @override
  State<_RpgModeTile> createState() => _RpgModeTileState();
}

class _RpgModeTileState extends State<_RpgModeTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _glowAnimation;
  bool _showMagicEffect = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.95), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.05), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _rotateAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.05), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.05, end: -0.05), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.03), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.03, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  void _handleToggle(bool value) {
    if (value) {
      setState(() => _showMagicEffect = true);
      _controller.forward(from: 0.0).then((_) => setState(() => _showMagicEffect = false));
    }
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Stack(clipBehavior: Clip.none, children: [
        if (_showMagicEffect)
          Positioned.fill(child: AnimatedOpacity(
            opacity: _glowAnimation.value * 0.3, duration: const Duration(milliseconds: 100),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), boxShadow: [
                BoxShadow(color: Colors.purple.withOpacity(_glowAnimation.value * 0.5), blurRadius: 20 * _glowAnimation.value, spreadRadius: 5 * _glowAnimation.value),
                BoxShadow(color: Colors.amber.withOpacity(_glowAnimation.value * 0.3), blurRadius: 30 * _glowAnimation.value, spreadRadius: 10 * _glowAnimation.value),
              ]),
            ),
          )),
        Transform.scale(scale: _scaleAnimation.value, child: Transform.rotate(angle: _rotateAnimation.value,
          child: Container(
            margin: _showMagicEffect ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4) : EdgeInsets.zero,
            decoration: _showMagicEffect ? BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber.withOpacity(_glowAnimation.value * 0.8), width: 2)) : null,
            child: SwitchListTile(
              secondary: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: widget.isEnabled ? Colors.purple.withValues(alpha: 0.2) : theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: RotationTransition(turns: Tween(begin: 0.5, end: 1.0).animate(animation), child: child)),
                  child: Icon(widget.isEnabled ? Icons.auto_awesome : Icons.auto_awesome_outlined, key: ValueKey(widget.isEnabled), color: widget.isEnabled ? Colors.amber : null),
                ),
              ),
              title: Text(l10n.settingsRPGMode, style: TextStyle(fontWeight: widget.isEnabled ? FontWeight.bold : FontWeight.normal, color: widget.isEnabled ? Colors.amber.shade700 : null)),
              subtitle: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(widget.isEnabled ? l10n.settingsRPGModeActive : l10n.settingsRPGModeSubtitle, key: ValueKey(widget.isEnabled), style: TextStyle(color: widget.isEnabled ? Colors.purple : null, fontStyle: widget.isEnabled ? FontStyle.italic : FontStyle.normal)),
              ),
              value: widget.isEnabled,
              onChanged: _handleToggle,
            ),
          ),
        )),
        if (_showMagicEffect)
          ...List.generate(8, (i) {
            final r = 40 + (i % 3) * 20.0;
            return Positioned(
              left: MediaQuery.of(context).size.width / 2 + r * _glowAnimation.value * (i.isEven ? 1 : -1) * (0.5 + 0.5 * (i % 3)) - 10,
              top: 30 + r * _glowAnimation.value * (i < 4 ? -1 : 1) * 0.5,
              child: AnimatedOpacity(opacity: (1 - _glowAnimation.value).clamp(0.0, 1.0), duration: const Duration(milliseconds: 100),
                  child: Text(['\u2728', '\u2B50', '\u{1F4AB}', '\u{1F31F}'][i % 4], style: TextStyle(fontSize: 12 + (i % 3) * 4.0))),
            );
          }),
      ]),
    );
  }
}

// ════════════════════════════════════════════
//  INTEGRATIONS SECTION
// ════════════════════════════════════════════

class _IntegrationsSection extends ConsumerStatefulWidget {
  const _IntegrationsSection();
  @override
  ConsumerState<_IntegrationsSection> createState() => _IntegrationsSectionState();
}

class _IntegrationsSectionState extends ConsumerState<_IntegrationsSection> {
  bool _instacartConfigured = false;
  bool _krogerConfigured = false;
  bool _discordLinked = false;
  bool _loading = true;

  @override
  void initState() { super.initState(); _checkStoreStatus(); }

  Future<void> _checkStoreStatus() async {
    final ic = await GroceryService.isConfigured(GroceryProvider.instacart);
    final kr = await GroceryService.isConfigured(GroceryProvider.kroger);
    bool discord = false;
    try {
      if (AuthService.instance.isSignedIn) {
        final status = await AuthService.instance.getDiscordStatus();
        discord = status.linked;
      }
    } catch (_) {}
    if (mounted) setState(() { _instacartConfigured = ic; _krogerConfigured = kr; _discordLinked = discord; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return _Section(title: l10n.settingsIntegrations, icon: Icons.extension_outlined, children: [
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF5865F2).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Icon(Icons.forum_outlined, size: 20, color: Color(0xFF5865F2)))),
        title: Text(l10n.discord, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        subtitle: Text(_loading ? l10n.integrationsChecking : _discordLinked ? l10n.integrationsLinkedManage : l10n.integrationsTapToLink,
            style: TextStyle(fontSize: 13, color: _discordLinked ? const Color(0xFF43B02A) : theme.colorScheme.outline)),
        trailing: _discordLinked ? const Icon(Icons.check_circle, color: Color(0xFF43B02A), size: 20) : Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
        onTap: () => _showDiscordOptions(context),
      ),
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF43B02A).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Text('\u{1F955}', style: TextStyle(fontSize: 18)))),
        title: Text(l10n.instacart, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        subtitle: Text(_loading ? l10n.integrationsChecking : _instacartConfigured ? l10n.integrationsConnectedManage : l10n.integrationsNotConnected,
            style: TextStyle(fontSize: 13, color: _instacartConfigured ? const Color(0xFF43B02A) : theme.colorScheme.outline)),
        trailing: _instacartConfigured ? const Icon(Icons.check_circle, color: Color(0xFF43B02A), size: 20) : Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
        onTap: () => _showInstacartOptions(context),
      ),
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF0068B5).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Text('\u{1F3EA}', style: TextStyle(fontSize: 18)))),
        title: Text(l10n.kroger, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        subtitle: Text(_loading ? l10n.integrationsChecking : _krogerConfigured ? l10n.integrationsConnectedManage : l10n.integrationsTapToSignIn,
            style: TextStyle(fontSize: 13, color: _krogerConfigured ? const Color(0xFF43B02A) : theme.colorScheme.outline)),
        trailing: _krogerConfigured ? const Icon(Icons.check_circle, color: Color(0xFF43B02A), size: 20) : Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
        onTap: () => _showKrogerOptions(context),
      ),
    ]);
  }

  void _showDiscordOptions(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final auth = AuthService.instance;
    showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        const Icon(Icons.forum, size: 24, color: Color(0xFF5865F2)), const SizedBox(width: 12),
        Text(l10n.discord, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        if (_discordLinked) ...[const SizedBox(width: 8), Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: const Color(0xFF43B02A).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
          child: Text(l10n.integrationsLinked, style: const TextStyle(color: Color(0xFF43B02A), fontSize: 11, fontWeight: FontWeight.w600)),
        )],
      ])),
      if (!_discordLinked)
        ListTile(leading: const Icon(Icons.link), title: Text(l10n.discordLinkAccount), subtitle: Text(l10n.discordLinkSubtitle), onTap: () async {
          Navigator.pop(ctx);
          if (!auth.isSignedIn) { if (context.mounted) AppSnackbar.error(context, l10n.discordSignInFirst); return; }
          final url = Uri.parse(auth.discordLinkUrl);
          try { await launchUrl(url, mode: LaunchMode.externalApplication); } catch (e) { if (context.mounted) AppSnackbar.error(context, l10n.couldNotOpenBrowser); }
        }),
      if (_discordLinked)
        ListTile(leading: Icon(Icons.link_off, color: theme.colorScheme.error), title: Text(l10n.discordUnlink, style: TextStyle(color: theme.colorScheme.error)), subtitle: Text(l10n.discordUnlinkSubtitle), onTap: () async {
          Navigator.pop(ctx);
          final success = await auth.unlinkDiscord();
          if (success) { _checkStoreStatus(); if (context.mounted) AppSnackbar.success(context, l10n.discordUnlinked); }
          else { if (context.mounted) AppSnackbar.error(context, l10n.discordUnlinkFailed); }
        }),
      const SizedBox(height: 16),
    ])));
  }

  void _showInstacartOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        const Text('\u{1F955}', style: TextStyle(fontSize: 24)), const SizedBox(width: 12),
        Text(l10n.instacart, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        if (_instacartConfigured) ...[const SizedBox(width: 8), Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: const Color(0xFF43B02A).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
          child: Text(l10n.connected, style: const TextStyle(color: Color(0xFF43B02A), fontSize: 11, fontWeight: FontWeight.w600)),
        )],
      ])),
      const SizedBox(height: 16),
    ])));
  }

  void _showKrogerOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        const Text('\u{1F3EA}', style: TextStyle(fontSize: 24)), const SizedBox(width: 12),
        Text(l10n.kroger, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        if (_krogerConfigured) ...[const SizedBox(width: 8), Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: const Color(0xFF43B02A).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
          child: Text(l10n.connected, style: const TextStyle(color: Color(0xFF43B02A), fontSize: 11, fontWeight: FontWeight.w600)),
        )],
      ])),
      if (!_krogerConfigured)
        ListTile(leading: const Icon(Icons.login), title: Text(l10n.signInToKroger), subtitle: Text(l10n.connectToAddItems), onTap: () async { Navigator.pop(ctx); await GroceryService.krogerStartOAuthLogin(); }),
      ListTile(leading: const Icon(Icons.location_on_outlined), title: Text(l10n.setPreferredStore), subtitle: Text(l10n.searchByZipCode), onTap: () { Navigator.pop(ctx); _showKrogerLocationDialog(context); }),
      if (_krogerConfigured)
        ListTile(leading: Icon(Icons.link_off, color: theme.colorScheme.error), title: Text(l10n.disconnect, style: TextStyle(color: theme.colorScheme.error)), onTap: () async { Navigator.pop(ctx); await GroceryService.disconnect(GroceryProvider.kroger); _checkStoreStatus(); }),
      const SizedBox(height: 16),
    ])));
  }

  void _showKrogerLocationDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final theme = Theme.of(context);
    showDialog(context: context, builder: (ctx) {
      List<Map<String, dynamic>> results = [];
      bool searching = false;
      return StatefulBuilder(builder: (ctx, ss) => AlertDialog(
        title: Text(l10n.findYourKrogerStore),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: controller, decoration: InputDecoration(
            hintText: l10n.enterZipCode, border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: searching ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search),
              onPressed: () async {
                final zip = controller.text.trim(); if (zip.isEmpty) return;
                ss(() => searching = true);
                final locs = await GroceryService.krogerSearchLocations(zip);
                ss(() { results = locs; searching = false; });
              },
            ),
          ), keyboardType: TextInputType.number),
          if (results.isNotEmpty) ...[
            const SizedBox(height: 12),
            ConstrainedBox(constraints: const BoxConstraints(maxHeight: 200), child: ListView.builder(
              shrinkWrap: true, itemCount: results.length,
              itemBuilder: (_, i) {
                final loc = results[i];
                return ListTile(dense: true, title: Text(loc['name'] ?? 'Store'),
                  subtitle: Text('${loc['address'] ?? ''}, ${loc['city'] ?? ''} ${loc['state'] ?? ''}', style: theme.textTheme.bodySmall),
                  onTap: () async {
                    final id = loc['id']?.toString();
                    if (id != null) await GroceryService.setKrogerLocation(id);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) AppSnackbar.success(context, l10n.storeSet(loc['name'] ?? 'Kroger'));
                  },
                );
              },
            )),
          ],
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionClose))],
      ));
    });
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
      appBar: AppBar(title: const Text('Advanced Settings')),
      body: ListView(children: [
        _Section(title: 'Manage', icon: Icons.tune, children: [
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
    final buttonLabel = _allChecked ? l.exportFullBackup : _noneChecked ? 'None Selected' : 'Partial Backup';
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