import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipespellbook/l10n/app_localizations.dart';
import '../../../providers/settings_provider.dart';
import '../../../utils/responsive_utils.dart';

/// Where Settings > Home screen lives. The old Quick Access address opens
/// it too.
const homeScreenSettingsPath = '/settings/home-screen';

/// Settings > Home screen: a switch for every section of Home, so people can
/// clear off what they do not use. The greeting with the cookbook switcher,
/// the search bar and the add button always stay. "Jump back in" keeps the
/// Quick Access choices of what goes into it (today's meals, pinned and
/// recently viewed recipes, and how many of those).
class HomeScreenSettingsScreen extends ConsumerWidget {
  const HomeScreenSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    Widget section(HomeSection s, IconData icon, String title, String description) => SwitchListTile(
          key: ValueKey('home-section-${s.name}'),
          secondary: Icon(icon),
          title: Text(title),
          subtitle: Text(description),
          value: settings.showsHomeSection(s),
          onChanged: (v) => notifier.setHomeSectionShown(s, v),
        );

    // What goes into "Jump back in", under it while it is on.
    Widget source(String key, String title, bool value, ValueChanged<bool> onChanged) => SwitchListTile(
          key: ValueKey(key),
          dense: true,
          contentPadding: const EdgeInsetsDirectional.only(start: 72, end: 16),
          title: Text(title),
          value: value,
          onChanged: onChanged,
        );
    final jumpBackIn = settings.showsHomeSection(HomeSection.jumpBackIn);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsHomeScreen)),
      body: Responsive.constrainWidth(
        context,
        maxWidth: Responsive.settingsListMaxWidth,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                l10n.homeSettingsIntro,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),

            _SectionHeader(title: l10n.homeSettingsGroupPlanning),
            section(HomeSection.nextSevenDays, Icons.calendar_today_outlined, l10n.homeNextSevenDays,
                l10n.homeSectionNextSevenDaysDesc),
            section(HomeSection.shoppingList, Icons.shopping_basket_outlined, l10n.homeSectionShoppingList,
                l10n.homeSectionShoppingListDesc),
            section(HomeSection.whatCanIMake, Icons.kitchen_outlined, l10n.pantryCookTitle,
                l10n.homeSectionWhatCanIMakeDesc),
            section(HomeSection.dinnerIdeas, Icons.dinner_dining_outlined, l10n.dinnerTitle,
                l10n.homeSectionDinnerDesc),

            _SectionHeader(title: l10n.settingsRecipes),
            section(HomeSection.libraryChips, Icons.restaurant_menu_outlined, l10n.homeSectionLibraryChips,
                l10n.homeSectionLibraryChipsDesc),
            section(HomeSection.jumpBackIn, Icons.history_rounded, l10n.homeJumpBackIn,
                l10n.homeSectionJumpBackInDesc),
            if (jumpBackIn) ...[
              source('jump-back-in-meals', l10n.homeJumpBackInMeals, settings.quickAccessShowMealPlan,
                  notifier.setQuickAccessShowMealPlan),
              source('jump-back-in-pinned', l10n.homeJumpBackInPinned, settings.quickAccessShowPinned,
                  notifier.setQuickAccessShowPinned),
              source('jump-back-in-recent', l10n.homeJumpBackInRecent, settings.quickAccessShowHistory,
                  notifier.setQuickAccessShowHistory),
              if (settings.quickAccessShowHistory)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 72, end: 16, bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.homeJumpBackInRecentCount,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: Slider(
                          value: settings.quickAccessHistoryCount.clamp(3, 20).toDouble(),
                          min: 3,
                          max: 20,
                          divisions: 17,
                          label: '${settings.quickAccessHistoryCount}',
                          onChanged: (v) => notifier.setQuickAccessHistoryCount(v.round()),
                        ),
                      ),
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${settings.quickAccessHistoryCount}',
                          textAlign: TextAlign.end,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            section(HomeSection.favorites, Icons.favorite_border_rounded, l10n.favoritesTitle,
                l10n.homeSectionFavoritesDesc),
            section(HomeSection.browse, Icons.category_outlined, l10n.homeSectionBrowse, l10n.homeSectionBrowseDesc),
            section(HomeSection.cookbookShelf, Icons.menu_book_outlined, l10n.navCookbooks,
                l10n.homeSectionCookbooksDesc),

            _SectionHeader(title: l10n.homeSettingsGroupTips),
            SwitchListTile(
              key: const ValueKey('home-section-craving'),
              secondary: const Icon(Icons.auto_awesome_outlined),
              title: Text(l10n.cravingCardTitle),
              subtitle: Text(l10n.homeSectionCravingDesc),
              value: settings.showSurpriseMe,
              onChanged: notifier.setShowSurpriseMe,
            ),
            section(HomeSection.guidesTip, Icons.lightbulb_outline_rounded, l10n.homeSectionGuides,
                l10n.homeSectionGuidesDesc),
            section(HomeSection.backupReminder, Icons.cloud_off_outlined, l10n.homeSectionBackup,
                l10n.homeSectionBackupDesc),
            section(HomeSection.cookbookUpdates, Icons.update_rounded, l10n.homeSectionCookbookUpdates,
                l10n.homeSectionCookbookUpdatesDesc),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
