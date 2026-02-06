// lib/data/rpg/rpg_text.dart
// Centralized RPG text overrides for nerd mode
// When nerdMode is on, these replace standard UI text with RPG-flavored versions.

import 'package:recipespellbook/l10n/app_localizations.dart';

/// Provides RPG-flavored text when nerd mode is enabled.
/// Falls back to standard l10n strings when nerd mode is off.
class RpgText {
  final AppLocalizations l10n;
  final bool nerdMode;

  const RpgText(this.l10n, this.nerdMode);

  // ============ NAVIGATION ============

  String get navHome => nerdMode ? 'Base Camp' : l10n.navHome;
  String get navPlanner => nerdMode ? 'Battle Plan' : l10n.navPlanner;
  String get navShopping => nerdMode ? 'Supplies' : l10n.navShopping;
  String get navMenu => nerdMode ? 'Guild Hall' : l10n.navMenu;
  String get navCookbooks => nerdMode ? 'Spellbooks' : l10n.navCookbooks;

  // ============ SCREEN TITLES ============

  String get cookbooksTitle => nerdMode ? 'Spellbooks' : l10n.cookbooksTitle;
  String get categoriesTitle => nerdMode ? 'Schools of Magic' : l10n.categoriesTitle;
  String get coursesTitle => nerdMode ? 'Spell Types' : l10n.coursesTitle;

  // ============ RECIPE SECTIONS ============

  // Ingredients stays the same per user request
  String get ingredientsTitle => l10n.ingredientsTitle;
  String get instructionsTitle => nerdMode ? 'Incantation' : l10n.instructionsTitle;
  String get nutritionTitle => nerdMode ? 'Power Stats' : l10n.nutritionTitle;

  // ============ RECIPE META ============

  String get recipeFieldPrepTime => nerdMode ? 'Ritual Time' : l10n.recipeFieldPrepTime;
  String get recipeFieldCookTime => nerdMode ? 'Casting Time' : l10n.recipeFieldCookTime;
  String get recipeFieldServings => nerdMode ? 'Party Size' : l10n.recipeFieldServings;
  String get recipeFieldNotes => nerdMode ? 'Arcane Notes' : l10n.recipeFieldNotes;

  // ============ ACTIONS ============

  String get addRecipe => nerdMode ? 'Inscribe Scroll' : l10n.recipeAdd;
  String get importRecipe => nerdMode ? 'Discover Scroll' : l10n.importFromURL;
  String get importGuides => nerdMode ? 'Scroll Discovery' : l10n.importGuides;
  String get inviteFriends => nerdMode ? 'Summon Allies' : 'Invite friends';

  // ============ FAVORITES / PINS ============

  String get homePinnedRecipes => nerdMode ? 'Bookmarked Scrolls' : l10n.homePinnedRecipes;
  String get homeRecentRecipes => nerdMode ? 'Recent Scrolls' : l10n.homeRecentRecipes;

  // ============ MEAL PLAN ============

  String get mealPlanButton => nerdMode ? 'Battle Plan' : l10n.mealPlanButton;
  String get groceriesButton => nerdMode ? 'Quest Supplies' : l10n.groceriesButton;

  // ============ DRAWER SECTIONS ============

  String get sectionNavigation => nerdMode ? 'QUEST LOG' : 'NAVIGATION';
  String get sectionImport => nerdMode ? 'SCROLL ARCHIVES' : 'IMPORT';
  String get sectionSocial => nerdMode ? 'GUILD' : 'SOCIAL';
  String get sectionApp => nerdMode ? 'SETTINGS' : 'APP';
  String get sectionRpg => 'ADVENTURE';

  // ============ DRAWER ITEMS ============

  String get community => nerdMode ? 'The Tavern' : 'Community';
  String get useOnDesktop => nerdMode ? 'Enchant More Devices' : 'Use on desktop';
  String get profile => nerdMode ? 'Adventurer Profile' : 'Profile';
  String get achievements => nerdMode ? 'Quests & Feats' : 'Achievements';
  String get cosmetics => nerdMode ? 'Wardrobe' : 'Cosmetics';
  String get leaderboards => nerdMode ? 'Hall of Fame' : 'Leaderboards';
  String get bossBattles => nerdMode ? 'Boss Battles' : 'Boss Battles';

  // ============ MISC ============

  String get trashTitle => nerdMode ? 'The Void' : 'Trash';
  String get scaleRecipeButton => nerdMode ? 'Scale Potion' : l10n.scaleRecipeButton;
  String get convertUnitsButton => nerdMode ? 'Transmute Units' : l10n.convertUnitsButton;

  // ============ INVITE SHEET ============

  String get inviteTitle => nerdMode ? 'Summon Allies' : 'Invite Friends';
  String get inviteSubtitle => nerdMode
      ? 'Rally your fellow adventurers to join the quest!'
      : 'Invite your friends and family to start cooking together!';
  String get inviteButton => nerdMode ? 'Send Summoning Scroll' : 'Share Invite Link';

  // ============ FACTORY ============

  /// Convenience factory — use in any ConsumerWidget:
  ///   final rpg = RpgText.of(l10n, ref.watch(settingsProvider).nerdMode);
  static RpgText of(AppLocalizations l10n, bool nerdMode) =>
      RpgText(l10n, nerdMode);
}