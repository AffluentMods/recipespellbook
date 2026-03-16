import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipe Spellbook'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCookbooks.
  ///
  /// In en, this message translates to:
  /// **'Cookbooks'**
  String get navCookbooks;

  /// No description provided for @navPlanner.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get navPlanner;

  /// No description provided for @navShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get navShopping;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get homeGreeting;

  /// No description provided for @homeQuickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get homeQuickAccess;

  /// No description provided for @homeMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Meals'**
  String get homeMealPlan;

  /// No description provided for @homePinnedRecipes.
  ///
  /// In en, this message translates to:
  /// **'Pinned Recipes'**
  String get homePinnedRecipes;

  /// No description provided for @homeRecentRecipes.
  ///
  /// In en, this message translates to:
  /// **'Recently Viewed'**
  String get homeRecentRecipes;

  /// No description provided for @homeNoMealsPlanned.
  ///
  /// In en, this message translates to:
  /// **'No meals planned for today'**
  String get homeNoMealsPlanned;

  /// No description provided for @homeNoPinnedRecipes.
  ///
  /// In en, this message translates to:
  /// **'No pinned recipes yet'**
  String get homeNoPinnedRecipes;

  /// No description provided for @homeNoRecentRecipes.
  ///
  /// In en, this message translates to:
  /// **'No recent recipes'**
  String get homeNoRecentRecipes;

  /// No description provided for @recipesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipesTitle;

  /// No description provided for @recipesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet'**
  String get recipesEmpty;

  /// No description provided for @recipesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first recipe to get started'**
  String get recipesEmptySubtitle;

  /// No description provided for @recipeAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Recipe'**
  String get recipeAdd;

  /// No description provided for @recipeEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Recipe'**
  String get recipeEdit;

  /// No description provided for @recipeDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Recipe'**
  String get recipeDelete;

  /// No description provided for @recipeDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this recipe?'**
  String get recipeDeleteConfirm;

  /// No description provided for @recipeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get recipeFavorite;

  /// No description provided for @recipeUnfavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get recipeUnfavorite;

  /// No description provided for @recipePin.
  ///
  /// In en, this message translates to:
  /// **'Pin recipe'**
  String get recipePin;

  /// No description provided for @recipeUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin recipe'**
  String get recipeUnpin;

  /// No description provided for @recipeShare.
  ///
  /// In en, this message translates to:
  /// **'Share recipe'**
  String get recipeShare;

  /// No description provided for @recipePrint.
  ///
  /// In en, this message translates to:
  /// **'Print recipe'**
  String get recipePrint;

  /// No description provided for @recipeDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate recipe'**
  String get recipeDuplicate;

  /// No description provided for @recipeAddToMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Add to meal plan'**
  String get recipeAddToMealPlan;

  /// No description provided for @recipeAddToShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Add to shopping list'**
  String get recipeAddToShoppingList;

  /// No description provided for @recipeStartCooking.
  ///
  /// In en, this message translates to:
  /// **'Start Cooking'**
  String get recipeStartCooking;

  /// No description provided for @recipeFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get recipeFieldTitle;

  /// No description provided for @recipeFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get recipeFieldDescription;

  /// No description provided for @recipeFieldIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get recipeFieldIngredients;

  /// No description provided for @recipeFieldInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get recipeFieldInstructions;

  /// No description provided for @recipeFieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get recipeFieldNotes;

  /// No description provided for @notesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesTitle;

  /// No description provided for @recipeFieldServings.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get recipeFieldServings;

  /// No description provided for @recipeFieldPrepTime.
  ///
  /// In en, this message translates to:
  /// **'Prep Time'**
  String get recipeFieldPrepTime;

  /// No description provided for @recipeFieldCookTime.
  ///
  /// In en, this message translates to:
  /// **'Cook Time'**
  String get recipeFieldCookTime;

  /// No description provided for @recipeFieldTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get recipeFieldTotalTime;

  /// No description provided for @recipeFieldSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get recipeFieldSource;

  /// No description provided for @recipeFieldCourse.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get recipeFieldCourse;

  /// No description provided for @recipeFieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get recipeFieldCategory;

  /// No description provided for @recipeFieldTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get recipeFieldTags;

  /// No description provided for @recipeFieldRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get recipeFieldRating;

  /// No description provided for @ratingCommon.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get ratingCommon;

  /// No description provided for @ratingUncommon.
  ///
  /// In en, this message translates to:
  /// **'Uncommon'**
  String get ratingUncommon;

  /// No description provided for @ratingRare.
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get ratingRare;

  /// No description provided for @ratingEpic.
  ///
  /// In en, this message translates to:
  /// **'Epic'**
  String get ratingEpic;

  /// No description provided for @ratingLegendary.
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get ratingLegendary;

  /// No description provided for @ratingUnrated.
  ///
  /// In en, this message translates to:
  /// **'Unrated'**
  String get ratingUnrated;

  /// No description provided for @minutesAbbrev.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesAbbrev;

  /// No description provided for @hoursAbbrev.
  ///
  /// In en, this message translates to:
  /// **'hr'**
  String get hoursAbbrev;

  /// No description provided for @servingsUnit.
  ///
  /// In en, this message translates to:
  /// **'servings'**
  String get servingsUnit;

  /// No description provided for @ingredientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredientsTitle;

  /// No description provided for @ingredientsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No ingredients added'**
  String get ingredientsEmpty;

  /// No description provided for @ingredientAdd.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get ingredientAdd;

  /// No description provided for @ingredientPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g., 2 cups flour'**
  String get ingredientPlaceholder;

  /// No description provided for @instructionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructionsTitle;

  /// No description provided for @instructionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No instructions added'**
  String get instructionsEmpty;

  /// No description provided for @instructionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add step'**
  String get instructionAdd;

  /// No description provided for @instructionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Describe this step...'**
  String get instructionPlaceholder;

  /// No description provided for @stepNumber.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String stepNumber(int number);

  /// No description provided for @cookbooksTitle.
  ///
  /// In en, this message translates to:
  /// **'Cookbooks'**
  String get cookbooksTitle;

  /// No description provided for @cookbooksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cookbooks yet'**
  String get cookbooksEmpty;

  /// No description provided for @cookbookAdd.
  ///
  /// In en, this message translates to:
  /// **'New Cookbook'**
  String get cookbookAdd;

  /// No description provided for @cookbookEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Cookbook'**
  String get cookbookEdit;

  /// No description provided for @cookbookDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Cookbook'**
  String get cookbookDelete;

  /// No description provided for @cookbookDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this cookbook and all its recipes?'**
  String get cookbookDeleteConfirm;

  /// No description provided for @cookbookRecipeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No recipes} =1{1 recipe} other{{count} recipes}}'**
  String cookbookRecipeCount(int count);

  /// No description provided for @shoppingDeli.
  ///
  /// In en, this message translates to:
  /// **'Deli'**
  String get shoppingDeli;

  /// No description provided for @shoppingCannedGoods.
  ///
  /// In en, this message translates to:
  /// **'Canned Goods & Soups'**
  String get shoppingCannedGoods;

  /// No description provided for @shoppingCondiments.
  ///
  /// In en, this message translates to:
  /// **'Condiments & Sauces'**
  String get shoppingCondiments;

  /// No description provided for @shoppingGrainsAndPasta.
  ///
  /// In en, this message translates to:
  /// **'Grains, Pasta & Rice'**
  String get shoppingGrainsAndPasta;

  /// No description provided for @shoppingCookingAndBaking.
  ///
  /// In en, this message translates to:
  /// **'Cooking & Baking'**
  String get shoppingCookingAndBaking;

  /// No description provided for @shoppingBreakfastCereal.
  ///
  /// In en, this message translates to:
  /// **'Breakfast & Cereal'**
  String get shoppingBreakfastCereal;

  /// No description provided for @shoppingBeerWineSpirits.
  ///
  /// In en, this message translates to:
  /// **'Beer, Wine & Spirits'**
  String get shoppingBeerWineSpirits;

  /// No description provided for @shoppingBaby.
  ///
  /// In en, this message translates to:
  /// **'Baby'**
  String get shoppingBaby;

  /// No description provided for @shoppingPet.
  ///
  /// In en, this message translates to:
  /// **'Pet'**
  String get shoppingPet;

  /// No description provided for @shoppingHousehold.
  ///
  /// In en, this message translates to:
  /// **'Household'**
  String get shoppingHousehold;

  /// No description provided for @shoppingPersonalCare.
  ///
  /// In en, this message translates to:
  /// **'Personal Care'**
  String get shoppingPersonalCare;

  /// No description provided for @plannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal Planner'**
  String get plannerTitle;

  /// No description provided for @plannerEmpty.
  ///
  /// In en, this message translates to:
  /// **'No meals planned'**
  String get plannerEmpty;

  /// No description provided for @plannerEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a meal for this day'**
  String get plannerEmptySubtitle;

  /// No description provided for @plannerAddMeal.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get plannerAddMeal;

  /// No description provided for @plannerToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get plannerToday;

  /// No description provided for @plannerThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get plannerThisWeek;

  /// No description provided for @plannerBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get plannerBreakfast;

  /// No description provided for @plannerLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get plannerLunch;

  /// No description provided for @plannerDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get plannerDinner;

  /// No description provided for @plannerSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get plannerSnack;

  /// No description provided for @shoppingTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get shoppingTitle;

  /// No description provided for @shoppingEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your list is empty'**
  String get shoppingEmpty;

  /// No description provided for @shoppingEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add items or import from recipes'**
  String get shoppingEmptySubtitle;

  /// No description provided for @shoppingAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add item...'**
  String get shoppingAddItem;

  /// No description provided for @shoppingCheckedItems.
  ///
  /// In en, this message translates to:
  /// **'Checked Items'**
  String get shoppingCheckedItems;

  /// No description provided for @shoppingClearChecked.
  ///
  /// In en, this message translates to:
  /// **'Clear checked items'**
  String get shoppingClearChecked;

  /// No description provided for @shoppingClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all items'**
  String get shoppingClearAll;

  /// No description provided for @shoppingCategories.
  ///
  /// In en, this message translates to:
  /// **'Shopping Categories'**
  String get shoppingCategories;

  /// No description provided for @shoppingUncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get shoppingUncategorized;

  /// No description provided for @shoppingItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String shoppingItemCount(int count);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get settingsThemeMode;

  /// No description provided for @settingsThemeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeModeSystem;

  /// No description provided for @settingsThemeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeModeLight;

  /// No description provided for @settingsThemeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeModeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get settingsMeasurements;

  /// No description provided for @settingsMeasurementsUS.
  ///
  /// In en, this message translates to:
  /// **'US (cups, oz)'**
  String get settingsMeasurementsUS;

  /// No description provided for @settingsMeasurementsMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric (ml, g)'**
  String get settingsMeasurementsMetric;

  /// No description provided for @settingsKitchenBuddy.
  ///
  /// In en, this message translates to:
  /// **'Kitchen Buddy'**
  String get settingsKitchenBuddy;

  /// No description provided for @settingsKitchenBuddySubtitle.
  ///
  /// In en, this message translates to:
  /// **'A cute chef companion you dress up with coins'**
  String get settingsKitchenBuddySubtitle;

  /// No description provided for @settingsRecipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get settingsRecipes;

  /// No description provided for @settingsManageCourses.
  ///
  /// In en, this message translates to:
  /// **'Manage Courses'**
  String get settingsManageCourses;

  /// No description provided for @settingsManageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get settingsManageCategories;

  /// No description provided for @settingsManageTags.
  ///
  /// In en, this message translates to:
  /// **'Manage Tags'**
  String get settingsManageTags;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get settingsExport;

  /// No description provided for @settingsExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Backup your recipes'**
  String get settingsExportSubtitle;

  /// No description provided for @settingsImport.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get settingsImport;

  /// No description provided for @settingsImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get settingsImportSubtitle;

  /// No description provided for @settingsImportFromApps.
  ///
  /// In en, this message translates to:
  /// **'Import from Other Apps'**
  String get settingsImportFromApps;

  /// No description provided for @settingsImportFromAppsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Paprika, Crouton, Mela & more'**
  String get settingsImportFromAppsSubtitle;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacy;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTerms;

  /// No description provided for @settingsFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get settingsFeedback;

  /// No description provided for @importTitle.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importTitle;

  /// No description provided for @importCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get importCreate;

  /// No description provided for @importCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Write your own recipe'**
  String get importCreateSubtitle;

  /// No description provided for @importSubtitle.
  ///
  /// In en, this message translates to:
  /// **'From URL, image, or file'**
  String get importSubtitle;

  /// No description provided for @importChooseMethod.
  ///
  /// In en, this message translates to:
  /// **'How would you like to add your recipe?'**
  String get importChooseMethod;

  /// No description provided for @importProgress.
  ///
  /// In en, this message translates to:
  /// **'Importing recipe...'**
  String get importProgress;

  /// No description provided for @importFromURL.
  ///
  /// In en, this message translates to:
  /// **'From URL'**
  String get importFromURL;

  /// No description provided for @importFromImage.
  ///
  /// In en, this message translates to:
  /// **'From Image'**
  String get importFromImage;

  /// No description provided for @importFromFile.
  ///
  /// In en, this message translates to:
  /// **'From File'**
  String get importFromFile;

  /// No description provided for @importFromText.
  ///
  /// In en, this message translates to:
  /// **'Import from Text'**
  String get importFromText;

  /// No description provided for @importProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get importProcessing;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Recipe imported successfully'**
  String get importSuccess;

  /// No description provided for @importError.
  ///
  /// In en, this message translates to:
  /// **'Failed to import recipe'**
  String get importError;

  /// No description provided for @importBulkTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Recipes'**
  String get importBulkTitle;

  /// No description provided for @importBulkFound.
  ///
  /// In en, this message translates to:
  /// **'Found {count} recipes'**
  String importBulkFound(int count);

  /// No description provided for @importBulkImportAll.
  ///
  /// In en, this message translates to:
  /// **'Import All'**
  String get importBulkImportAll;

  /// No description provided for @importBulkImportFirst.
  ///
  /// In en, this message translates to:
  /// **'Import First'**
  String get importBulkImportFirst;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search recipes...'**
  String get searchHint;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No recipes found'**
  String get searchNoResults;

  /// No description provided for @searchFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get searchFilters;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionCopy;

  /// No description provided for @actionPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get actionPaste;

  /// No description provided for @actionOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @actionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get errorNotFound;

  /// No description provided for @errorInvalidURL.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL'**
  String get errorInvalidURL;

  /// No description provided for @successSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get successSaved;

  /// No description provided for @successDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get successDeleted;

  /// No description provided for @successCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get successCopied;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get confirmDeleteMessage;

  /// No description provided for @emptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyStateTitle;

  /// No description provided for @emptyStateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get started by adding your first item'**
  String get emptyStateSubtitle;

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// No description provided for @dateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateYesterday;

  /// No description provided for @dateTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dateTomorrow;

  /// No description provided for @timeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{minute} other{minutes}}'**
  String timeMinutes(int count);

  /// No description provided for @timeHours.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{hour} other{hours}}'**
  String timeHours(int count);

  /// No description provided for @trashTitle.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trashTitle;

  /// No description provided for @trashEmpty.
  ///
  /// In en, this message translates to:
  /// **'Trash is empty'**
  String get trashEmpty;

  /// No description provided for @trashEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deleted recipes will appear here for 30 days'**
  String get trashEmptySubtitle;

  /// No description provided for @trashRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get trashRestore;

  /// No description provided for @trashRestored.
  ///
  /// In en, this message translates to:
  /// **'restored'**
  String get trashRestored;

  /// No description provided for @trashDeletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get trashDeletePermanently;

  /// No description provided for @trashEmptyTrash.
  ///
  /// In en, this message translates to:
  /// **'Empty trash'**
  String get trashEmptyTrash;

  /// No description provided for @trashEmptyConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all recipes in the trash. This action cannot be undone.'**
  String get trashEmptyConfirm;

  /// No description provided for @trashEmptied.
  ///
  /// In en, this message translates to:
  /// **'Trash emptied'**
  String get trashEmptied;

  /// No description provided for @trashDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get trashDeleted;

  /// No description provided for @trashDeletedToday.
  ///
  /// In en, this message translates to:
  /// **'Deleted today'**
  String get trashDeletedToday;

  /// No description provided for @trashDeletedYesterday.
  ///
  /// In en, this message translates to:
  /// **'Deleted yesterday'**
  String get trashDeletedYesterday;

  /// No description provided for @trashDeletedDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Deleted {days} days ago'**
  String trashDeletedDaysAgo(int days);

  /// No description provided for @trashExpiresToday.
  ///
  /// In en, this message translates to:
  /// **'Expires today'**
  String get trashExpiresToday;

  /// No description provided for @trashDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String trashDaysLeft(int days);

  /// No description provided for @cookingModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Cooking Mode'**
  String get cookingModeTitle;

  /// No description provided for @cookingSetTimer.
  ///
  /// In en, this message translates to:
  /// **'Set Timer'**
  String get cookingSetTimer;

  /// No description provided for @cookingTimerDone.
  ///
  /// In en, this message translates to:
  /// **'Timer Done!'**
  String get cookingTimerDone;

  /// No description provided for @cookingTimerFinished.
  ///
  /// In en, this message translates to:
  /// **'Your timer has finished.'**
  String get cookingTimerFinished;

  /// No description provided for @cookingExitTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit Cooking Mode?'**
  String get cookingExitTitle;

  /// No description provided for @cookingExitMessage.
  ///
  /// In en, this message translates to:
  /// **'Your progress will be lost.'**
  String get cookingExitMessage;

  /// No description provided for @cookingExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get cookingExit;

  /// No description provided for @cookingFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get cookingFinish;

  /// No description provided for @taxonomyAddCourse.
  ///
  /// In en, this message translates to:
  /// **'Add Course'**
  String get taxonomyAddCourse;

  /// No description provided for @taxonomyEditCourse.
  ///
  /// In en, this message translates to:
  /// **'Edit Course'**
  String get taxonomyEditCourse;

  /// No description provided for @taxonomyDeleteCourse.
  ///
  /// In en, this message translates to:
  /// **'Delete Course?'**
  String get taxonomyDeleteCourse;

  /// No description provided for @taxonomyAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get taxonomyAddCategory;

  /// No description provided for @taxonomyEditCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get taxonomyEditCategory;

  /// No description provided for @taxonomyDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category?'**
  String get taxonomyDeleteCategory;

  /// No description provided for @taxonomyBuiltIn.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get taxonomyBuiltIn;

  /// No description provided for @taxonomyCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get taxonomyCustom;

  /// No description provided for @taxonomyRestoreDefaults.
  ///
  /// In en, this message translates to:
  /// **'Restore Defaults'**
  String get taxonomyRestoreDefaults;

  /// No description provided for @taxonomyDefaultsRestored.
  ///
  /// In en, this message translates to:
  /// **'Custom items deleted, defaults restored'**
  String get taxonomyDefaultsRestored;

  /// No description provided for @taxonomyCourseName.
  ///
  /// In en, this message translates to:
  /// **'Course Name'**
  String get taxonomyCourseName;

  /// No description provided for @taxonomyCourseNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Brunch, Appetizer'**
  String get taxonomyCourseNameHint;

  /// No description provided for @taxonomyCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get taxonomyCategoryName;

  /// No description provided for @taxonomyCategoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Gluten-Free, Low-Carb'**
  String get taxonomyCategoryNameHint;

  /// No description provided for @taxonomyEmojiHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the emoji field to change it'**
  String get taxonomyEmojiHint;

  /// No description provided for @taxonomyDeleteCourseMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? Recipes using this course will become uncategorized.'**
  String taxonomyDeleteCourseMessage(String name);

  /// No description provided for @taxonomyDeleteCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? Recipes using this category will become uncategorized.'**
  String taxonomyDeleteCategoryMessage(String name);

  /// No description provided for @settingsQuickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get settingsQuickAccess;

  /// No description provided for @settingsPlaceholders.
  ///
  /// In en, this message translates to:
  /// **'Image Placeholders'**
  String get settingsPlaceholders;

  /// No description provided for @actionView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get actionView;

  /// No description provided for @browseViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All Recipes'**
  String get browseViewAll;

  /// No description provided for @browseRecipesTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} recipes total'**
  String browseRecipesTotal(int count);

  /// No description provided for @browseCourses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get browseCourses;

  /// No description provided for @browseCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get browseCategories;

  /// No description provided for @browseNoCourse.
  ///
  /// In en, this message translates to:
  /// **'No Course'**
  String get browseNoCourse;

  /// No description provided for @browseUncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get browseUncategorized;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No favorite recipes yet'**
  String get favoritesEmpty;

  /// No description provided for @favoritesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the star on any recipe to add it here'**
  String get favoritesEmptySubtitle;

  /// No description provided for @favoritesRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get favoritesRemoved;

  /// No description provided for @recentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recently Viewed'**
  String get recentTitle;

  /// No description provided for @recentEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recently viewed recipes'**
  String get recentEmpty;

  /// No description provided for @recentEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recipes you view will appear here'**
  String get recentEmptySubtitle;

  /// No description provided for @recentJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get recentJustNow;

  /// No description provided for @recentMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String recentMinutesAgo(int count);

  /// No description provided for @recentHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String recentHoursAgo(int count);

  /// No description provided for @recentYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get recentYesterday;

  /// No description provided for @recentDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String recentDaysAgo(int count);

  /// No description provided for @importFromUrl.
  ///
  /// In en, this message translates to:
  /// **'Import from URL'**
  String get importFromUrl;

  /// No description provided for @importUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Recipe URL'**
  String get importUrlHint;

  /// No description provided for @importUrlPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'https://example.com/recipe'**
  String get importUrlPlaceholder;

  /// No description provided for @importFetch.
  ///
  /// In en, this message translates to:
  /// **'Fetch Recipe'**
  String get importFetch;

  /// No description provided for @importFetching.
  ///
  /// In en, this message translates to:
  /// **'Fetching...'**
  String get importFetching;

  /// No description provided for @importPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get importPreview;

  /// No description provided for @importRecipeFound.
  ///
  /// In en, this message translates to:
  /// **'Recipe found!'**
  String get importRecipeFound;

  /// No description provided for @importReviewSave.
  ///
  /// In en, this message translates to:
  /// **'Review & Save'**
  String get importReviewSave;

  /// No description provided for @importEditBeforeSave.
  ///
  /// In en, this message translates to:
  /// **'You can edit the recipe before saving'**
  String get importEditBeforeSave;

  /// No description provided for @importSupportedSites.
  ///
  /// In en, this message translates to:
  /// **'Supported Sites'**
  String get importSupportedSites;

  /// No description provided for @importSupportedSitesInfo.
  ///
  /// In en, this message translates to:
  /// **'Works with most recipe sites including AllRecipes, Food Network, Tasty, BBC Good Food, Epicurious, Serious Eats, Bon Appétit, and many more!'**
  String get importSupportedSitesInfo;

  /// No description provided for @importFromScan.
  ///
  /// In en, this message translates to:
  /// **'Scan Recipe'**
  String get importFromScan;

  /// No description provided for @importFromPdf.
  ///
  /// In en, this message translates to:
  /// **'Import from PDF'**
  String get importFromPdf;

  /// No description provided for @cookbookNew.
  ///
  /// In en, this message translates to:
  /// **'New Cookbook'**
  String get cookbookNew;

  /// No description provided for @cookbookNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Cookbook Name'**
  String get cookbookNameLabel;

  /// No description provided for @cookbookNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Family Favorites'**
  String get cookbookNameHint;

  /// No description provided for @cookbookDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get cookbookDescLabel;

  /// No description provided for @cookbookDescHint.
  ///
  /// In en, this message translates to:
  /// **'A collection of recipes...'**
  String get cookbookDescHint;

  /// No description provided for @cookbookAddCover.
  ///
  /// In en, this message translates to:
  /// **'Add Cover'**
  String get cookbookAddCover;

  /// No description provided for @cookbookTapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap to add cover image'**
  String get cookbookTapToAdd;

  /// No description provided for @cookbookDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Cookbook?'**
  String get cookbookDeleteTitle;

  /// No description provided for @cookbookDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This cookbook contains {count} recipes. They will be moved to trash.'**
  String cookbookDeleteMessage(int count);

  /// No description provided for @cookbookCannotDelete.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete your only cookbook'**
  String get cookbookCannotDelete;

  /// No description provided for @fontSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get fontSizeTitle;

  /// No description provided for @fontSizeReset.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get fontSizeReset;

  /// No description provided for @fontSizeSmaller.
  ///
  /// In en, this message translates to:
  /// **'Smaller text'**
  String get fontSizeSmaller;

  /// No description provided for @fontSizeLarger.
  ///
  /// In en, this message translates to:
  /// **'Larger text'**
  String get fontSizeLarger;

  /// No description provided for @defaultCookbookName.
  ///
  /// In en, this message translates to:
  /// **'My Recipes'**
  String get defaultCookbookName;

  /// No description provided for @defaultCookbookDescription.
  ///
  /// In en, this message translates to:
  /// **'Your personal recipe collection'**
  String get defaultCookbookDescription;

  /// No description provided for @defaultShoppingListName.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get defaultShoppingListName;

  /// No description provided for @courseBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get courseBreakfast;

  /// No description provided for @courseLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get courseLunch;

  /// No description provided for @courseDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get courseDinner;

  /// No description provided for @courseAppetizer.
  ///
  /// In en, this message translates to:
  /// **'Appetizer'**
  String get courseAppetizer;

  /// No description provided for @courseSoup.
  ///
  /// In en, this message translates to:
  /// **'Soup'**
  String get courseSoup;

  /// No description provided for @courseSalad.
  ///
  /// In en, this message translates to:
  /// **'Salad'**
  String get courseSalad;

  /// No description provided for @courseMain.
  ///
  /// In en, this message translates to:
  /// **'Main Course'**
  String get courseMain;

  /// No description provided for @courseSide.
  ///
  /// In en, this message translates to:
  /// **'Side Dish'**
  String get courseSide;

  /// No description provided for @courseDessert.
  ///
  /// In en, this message translates to:
  /// **'Dessert'**
  String get courseDessert;

  /// No description provided for @courseSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get courseSnack;

  /// No description provided for @courseBeverage.
  ///
  /// In en, this message translates to:
  /// **'Beverage'**
  String get courseBeverage;

  /// No description provided for @categoryQuick.
  ///
  /// In en, this message translates to:
  /// **'Quick & Easy'**
  String get categoryQuick;

  /// No description provided for @categoryHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get categoryHealthy;

  /// No description provided for @categoryComfort.
  ///
  /// In en, this message translates to:
  /// **'Comfort Food'**
  String get categoryComfort;

  /// No description provided for @categoryVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get categoryVegetarian;

  /// No description provided for @categoryVegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get categoryVegan;

  /// No description provided for @categoryGlutenFree.
  ///
  /// In en, this message translates to:
  /// **'Gluten-Free'**
  String get categoryGlutenFree;

  /// No description provided for @categoryDairyFree.
  ///
  /// In en, this message translates to:
  /// **'Dairy-Free'**
  String get categoryDairyFree;

  /// No description provided for @categoryLowCarb.
  ///
  /// In en, this message translates to:
  /// **'Low Carb'**
  String get categoryLowCarb;

  /// No description provided for @categorySpicy.
  ///
  /// In en, this message translates to:
  /// **'Spicy'**
  String get categorySpicy;

  /// No description provided for @categoryFamilyFriendly.
  ///
  /// In en, this message translates to:
  /// **'Family Friendly'**
  String get categoryFamilyFriendly;

  /// No description provided for @categoryParty.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get categoryParty;

  /// No description provided for @categoryHoliday.
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get categoryHoliday;

  /// No description provided for @categoryBbq.
  ///
  /// In en, this message translates to:
  /// **'BBQ & Grill'**
  String get categoryBbq;

  /// No description provided for @categoryBaking.
  ///
  /// In en, this message translates to:
  /// **'Baking'**
  String get categoryBaking;

  /// No description provided for @shoppingProduce.
  ///
  /// In en, this message translates to:
  /// **'Produce'**
  String get shoppingProduce;

  /// No description provided for @shoppingDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy & Eggs'**
  String get shoppingDairy;

  /// No description provided for @shoppingMeat.
  ///
  /// In en, this message translates to:
  /// **'Meat & Poultry'**
  String get shoppingMeat;

  /// No description provided for @shoppingSeafood.
  ///
  /// In en, this message translates to:
  /// **'Seafood'**
  String get shoppingSeafood;

  /// No description provided for @shoppingBakery.
  ///
  /// In en, this message translates to:
  /// **'Bakery'**
  String get shoppingBakery;

  /// No description provided for @shoppingFrozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get shoppingFrozen;

  /// No description provided for @shoppingPantry.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get shoppingPantry;

  /// No description provided for @shoppingSpices.
  ///
  /// In en, this message translates to:
  /// **'Spices & Seasonings'**
  String get shoppingSpices;

  /// No description provided for @shoppingBeverages.
  ///
  /// In en, this message translates to:
  /// **'Beverages'**
  String get shoppingBeverages;

  /// No description provided for @shoppingSnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get shoppingSnacks;

  /// No description provided for @shoppingInternational.
  ///
  /// In en, this message translates to:
  /// **'International'**
  String get shoppingInternational;

  /// No description provided for @shoppingOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get shoppingOther;

  /// No description provided for @unitCup.
  ///
  /// In en, this message translates to:
  /// **'cup'**
  String get unitCup;

  /// No description provided for @unitCups.
  ///
  /// In en, this message translates to:
  /// **'cups'**
  String get unitCups;

  /// No description provided for @unitTablespoon.
  ///
  /// In en, this message translates to:
  /// **'tablespoon'**
  String get unitTablespoon;

  /// No description provided for @unitTablespoonAbbrev.
  ///
  /// In en, this message translates to:
  /// **'tbsp'**
  String get unitTablespoonAbbrev;

  /// No description provided for @unitTeaspoon.
  ///
  /// In en, this message translates to:
  /// **'teaspoon'**
  String get unitTeaspoon;

  /// No description provided for @unitTeaspoonAbbrev.
  ///
  /// In en, this message translates to:
  /// **'tsp'**
  String get unitTeaspoonAbbrev;

  /// No description provided for @unitFluidOunce.
  ///
  /// In en, this message translates to:
  /// **'fluid ounce'**
  String get unitFluidOunce;

  /// No description provided for @unitFluidOunceAbbrev.
  ///
  /// In en, this message translates to:
  /// **'fl oz'**
  String get unitFluidOunceAbbrev;

  /// No description provided for @unitPint.
  ///
  /// In en, this message translates to:
  /// **'pint'**
  String get unitPint;

  /// No description provided for @unitQuart.
  ///
  /// In en, this message translates to:
  /// **'quart'**
  String get unitQuart;

  /// No description provided for @unitGallon.
  ///
  /// In en, this message translates to:
  /// **'gallon'**
  String get unitGallon;

  /// No description provided for @unitMilliliter.
  ///
  /// In en, this message translates to:
  /// **'milliliter'**
  String get unitMilliliter;

  /// No description provided for @unitMilliliterAbbrev.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unitMilliliterAbbrev;

  /// No description provided for @unitLiter.
  ///
  /// In en, this message translates to:
  /// **'liter'**
  String get unitLiter;

  /// No description provided for @unitLiterAbbrev.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get unitLiterAbbrev;

  /// No description provided for @unitOunce.
  ///
  /// In en, this message translates to:
  /// **'ounce'**
  String get unitOunce;

  /// No description provided for @unitOunceAbbrev.
  ///
  /// In en, this message translates to:
  /// **'oz'**
  String get unitOunceAbbrev;

  /// No description provided for @unitPound.
  ///
  /// In en, this message translates to:
  /// **'pound'**
  String get unitPound;

  /// No description provided for @unitPoundAbbrev.
  ///
  /// In en, this message translates to:
  /// **'lb'**
  String get unitPoundAbbrev;

  /// No description provided for @unitGram.
  ///
  /// In en, this message translates to:
  /// **'gram'**
  String get unitGram;

  /// No description provided for @unitGramAbbrev.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get unitGramAbbrev;

  /// No description provided for @unitKilogram.
  ///
  /// In en, this message translates to:
  /// **'kilogram'**
  String get unitKilogram;

  /// No description provided for @unitKilogramAbbrev.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKilogramAbbrev;

  /// No description provided for @unitPinch.
  ///
  /// In en, this message translates to:
  /// **'pinch'**
  String get unitPinch;

  /// No description provided for @unitDash.
  ///
  /// In en, this message translates to:
  /// **'dash'**
  String get unitDash;

  /// No description provided for @unitClove.
  ///
  /// In en, this message translates to:
  /// **'clove'**
  String get unitClove;

  /// No description provided for @unitCloves.
  ///
  /// In en, this message translates to:
  /// **'cloves'**
  String get unitCloves;

  /// No description provided for @unitHead.
  ///
  /// In en, this message translates to:
  /// **'head'**
  String get unitHead;

  /// No description provided for @unitBunch.
  ///
  /// In en, this message translates to:
  /// **'bunch'**
  String get unitBunch;

  /// No description provided for @unitCan.
  ///
  /// In en, this message translates to:
  /// **'can'**
  String get unitCan;

  /// No description provided for @unitPackage.
  ///
  /// In en, this message translates to:
  /// **'package'**
  String get unitPackage;

  /// No description provided for @unitSlice.
  ///
  /// In en, this message translates to:
  /// **'slice'**
  String get unitSlice;

  /// No description provided for @unitSlices.
  ///
  /// In en, this message translates to:
  /// **'slices'**
  String get unitSlices;

  /// No description provided for @unitPiece.
  ///
  /// In en, this message translates to:
  /// **'piece'**
  String get unitPiece;

  /// No description provided for @unitPieces.
  ///
  /// In en, this message translates to:
  /// **'pieces'**
  String get unitPieces;

  /// No description provided for @unitWhole.
  ///
  /// In en, this message translates to:
  /// **'whole'**
  String get unitWhole;

  /// No description provided for @unitLarge.
  ///
  /// In en, this message translates to:
  /// **'large'**
  String get unitLarge;

  /// No description provided for @unitMedium.
  ///
  /// In en, this message translates to:
  /// **'medium'**
  String get unitMedium;

  /// No description provided for @unitSmall.
  ///
  /// In en, this message translates to:
  /// **'small'**
  String get unitSmall;

  /// No description provided for @unitFahrenheit.
  ///
  /// In en, this message translates to:
  /// **'°F'**
  String get unitFahrenheit;

  /// No description provided for @unitCelsius.
  ///
  /// In en, this message translates to:
  /// **'°C'**
  String get unitCelsius;

  /// No description provided for @unitInch.
  ///
  /// In en, this message translates to:
  /// **'inch'**
  String get unitInch;

  /// No description provided for @unitInches.
  ///
  /// In en, this message translates to:
  /// **'inches'**
  String get unitInches;

  /// No description provided for @unitInchAbbrev.
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get unitInchAbbrev;

  /// No description provided for @unitCentimeter.
  ///
  /// In en, this message translates to:
  /// **'centimeter'**
  String get unitCentimeter;

  /// No description provided for @unitCentimeterAbbrev.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get unitCentimeterAbbrev;

  /// No description provided for @unitMillimeter.
  ///
  /// In en, this message translates to:
  /// **'millimeter'**
  String get unitMillimeter;

  /// No description provided for @unitMillimeterAbbrev.
  ///
  /// In en, this message translates to:
  /// **'mm'**
  String get unitMillimeterAbbrev;

  /// No description provided for @convertUnitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Convert Units'**
  String get convertUnitsTitle;

  /// No description provided for @convertMetricToImperial.
  ///
  /// In en, this message translates to:
  /// **'Metric → Imperial'**
  String get convertMetricToImperial;

  /// No description provided for @convertMetricToImperialDesc.
  ///
  /// In en, this message translates to:
  /// **'ml → fl oz, g → oz, kg → lb'**
  String get convertMetricToImperialDesc;

  /// No description provided for @convertImperialToMetric.
  ///
  /// In en, this message translates to:
  /// **'Imperial → Metric'**
  String get convertImperialToMetric;

  /// No description provided for @convertImperialToMetricDesc.
  ///
  /// In en, this message translates to:
  /// **'cups → ml, oz → g, tsp → ml'**
  String get convertImperialToMetricDesc;

  /// No description provided for @convertResetToOriginal.
  ///
  /// In en, this message translates to:
  /// **'Reset to Original'**
  String get convertResetToOriginal;

  /// No description provided for @settingsRecipeLayout.
  ///
  /// In en, this message translates to:
  /// **'Recipe Layout'**
  String get settingsRecipeLayout;

  /// No description provided for @settingsRecipeLayoutDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how ingredients and instructions are displayed'**
  String get settingsRecipeLayoutDescription;

  /// No description provided for @settingsRecipeDisplay.
  ///
  /// In en, this message translates to:
  /// **'Recipe Display'**
  String get settingsRecipeDisplay;

  /// No description provided for @layoutStacked.
  ///
  /// In en, this message translates to:
  /// **'Stacked'**
  String get layoutStacked;

  /// No description provided for @layoutStackedDescription.
  ///
  /// In en, this message translates to:
  /// **'Show all content in a scrollable list'**
  String get layoutStackedDescription;

  /// No description provided for @layoutTabbed.
  ///
  /// In en, this message translates to:
  /// **'Tabbed'**
  String get layoutTabbed;

  /// No description provided for @layoutTabbedDescription.
  ///
  /// In en, this message translates to:
  /// **'Swipe between ingredients and instructions'**
  String get layoutTabbedDescription;

  /// No description provided for @recipeSwipeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe to switch sections'**
  String get recipeSwipeHint;

  /// No description provided for @recipeIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get recipeIngredients;

  /// No description provided for @recipeInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get recipeInstructions;

  /// No description provided for @dateNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get dateNextWeek;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String timeMinutesAgo(int count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String timeHoursAgo(int count);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String timeDaysAgo(int count);

  /// No description provided for @timeWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week ago} other{{count} weeks ago}}'**
  String timeWeeksAgo(int count);

  /// No description provided for @timeMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month ago} other{{count} months ago}}'**
  String timeMonthsAgo(int count);

  /// No description provided for @timeYearsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year ago} other{{count} years ago}}'**
  String timeYearsAgo(int count);

  /// No description provided for @timeInMinutes.
  ///
  /// In en, this message translates to:
  /// **'in {count, plural, =1{1 minute} other{{count} minutes}}'**
  String timeInMinutes(int count);

  /// No description provided for @timeInHours.
  ///
  /// In en, this message translates to:
  /// **'in {count, plural, =1{1 hour} other{{count} hours}}'**
  String timeInHours(int count);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String durationMinutes(int count);

  /// No description provided for @durationHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hr} other{{count} hrs}}'**
  String durationHours(int count);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr {minutes} min'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @countRecipes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No recipes} =1{1 recipe} other{{count} recipes}}'**
  String countRecipes(int count);

  /// No description provided for @countIngredients.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No ingredients} =1{1 ingredient} other{{count} ingredients}}'**
  String countIngredients(int count);

  /// No description provided for @countSteps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No steps} =1{1 step} other{{count} steps}}'**
  String countSteps(int count);

  /// No description provided for @countItems.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String countItems(int count);

  /// No description provided for @countSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String countSelected(int count);

  /// No description provided for @errorGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorGenericTitle;

  /// No description provided for @errorGenericMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGenericMessage;

  /// No description provided for @errorNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get errorNetworkTitle;

  /// No description provided for @errorNetworkMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get errorNetworkMessage;

  /// No description provided for @errorNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Not Found'**
  String get errorNotFoundTitle;

  /// No description provided for @errorNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'The requested content could not be found.'**
  String get errorNotFoundMessage;

  /// No description provided for @errorInvalidUrlTitle.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL'**
  String get errorInvalidUrlTitle;

  /// No description provided for @errorInvalidUrlMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL starting with http:// or https://'**
  String get errorInvalidUrlMessage;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get errorPermissionDenied;

  /// No description provided for @errorStorageFull.
  ///
  /// In en, this message translates to:
  /// **'Storage is full'**
  String get errorStorageFull;

  /// No description provided for @errorFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get errorFileNotFound;

  /// No description provided for @errorUnsupportedFormat.
  ///
  /// In en, this message translates to:
  /// **'Unsupported file format'**
  String get errorUnsupportedFormat;

  /// No description provided for @errorParsingFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse content'**
  String get errorParsingFailed;

  /// No description provided for @errorSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save'**
  String get errorSaveFailed;

  /// No description provided for @errorLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get errorLoadFailed;

  /// No description provided for @errorDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete'**
  String get errorDeleteFailed;

  /// No description provided for @errorImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to import'**
  String get errorImportFailed;

  /// No description provided for @errorExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to export'**
  String get errorExportFailed;

  /// No description provided for @errorCameraAccess.
  ///
  /// In en, this message translates to:
  /// **'Cannot access camera'**
  String get errorCameraAccess;

  /// No description provided for @errorGalleryAccess.
  ///
  /// In en, this message translates to:
  /// **'Cannot access photo library'**
  String get errorGalleryAccess;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out'**
  String get errorTimeout;

  /// No description provided for @errorServerError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get errorServerError;

  /// No description provided for @errorNoRecipeFound.
  ///
  /// In en, this message translates to:
  /// **'No recipe data found on this page'**
  String get errorNoRecipeFound;

  /// No description provided for @errorInvalidRecipe.
  ///
  /// In en, this message translates to:
  /// **'Invalid recipe data'**
  String get errorInvalidRecipe;

  /// No description provided for @errorDuplicateRecipe.
  ///
  /// In en, this message translates to:
  /// **'This recipe already exists'**
  String get errorDuplicateRecipe;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationTooShort.
  ///
  /// In en, this message translates to:
  /// **'Must be at least {min} characters'**
  String validationTooShort(int min);

  /// No description provided for @validationTooLong.
  ///
  /// In en, this message translates to:
  /// **'Must be less than {max} characters'**
  String validationTooLong(int max);

  /// No description provided for @validationInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validationInvalidEmail;

  /// No description provided for @validationInvalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL'**
  String get validationInvalidUrl;

  /// No description provided for @validationInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get validationInvalidNumber;

  /// No description provided for @validationMinValue.
  ///
  /// In en, this message translates to:
  /// **'Must be at least {min}'**
  String validationMinValue(int min);

  /// No description provided for @validationMaxValue.
  ///
  /// In en, this message translates to:
  /// **'Must be at most {max}'**
  String validationMaxValue(int max);

  /// No description provided for @photoTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get photoTakePhoto;

  /// No description provided for @photoChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get photoChooseFromGallery;

  /// No description provided for @photoRemoveImage.
  ///
  /// In en, this message translates to:
  /// **'Remove Image'**
  String get photoRemoveImage;

  /// No description provided for @shareAsText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get shareAsText;

  /// No description provided for @shareAsImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get shareAsImage;

  /// No description provided for @shareAsFile.
  ///
  /// In en, this message translates to:
  /// **'Share as File'**
  String get shareAsFile;

  /// No description provided for @shareQrCode.
  ///
  /// In en, this message translates to:
  /// **'Recipe QR Code'**
  String get shareQrCode;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @scalingOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get scalingOriginal;

  /// No description provided for @scalingHalf.
  ///
  /// In en, this message translates to:
  /// **'Half'**
  String get scalingHalf;

  /// No description provided for @scalingDouble.
  ///
  /// In en, this message translates to:
  /// **'Double'**
  String get scalingDouble;

  /// No description provided for @scalingTriple.
  ///
  /// In en, this message translates to:
  /// **'Triple'**
  String get scalingTriple;

  /// No description provided for @scalingCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get scalingCustom;

  /// No description provided for @scalingServings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 serving} other{{count} servings}}'**
  String scalingServings(int count);

  /// No description provided for @importRecipe.
  ///
  /// In en, this message translates to:
  /// **'Import Recipe'**
  String get importRecipe;

  /// No description provided for @importFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get importFile;

  /// No description provided for @importImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get importImage;

  /// No description provided for @importPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get importPaste;

  /// No description provided for @importPasteUrl.
  ///
  /// In en, this message translates to:
  /// **'Paste recipe URL'**
  String get importPasteUrl;

  /// No description provided for @importOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get importOr;

  /// No description provided for @importSupportsFormats.
  ///
  /// In en, this message translates to:
  /// **'Supports Paprika, Mela, JSON, ZIP exports'**
  String get importSupportsFormats;

  /// No description provided for @importFromSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Import your recipes from any social media platform or website.'**
  String get importFromSocialMedia;

  /// No description provided for @tagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsTitle;

  /// No description provided for @tagsSelect.
  ///
  /// In en, this message translates to:
  /// **'Select Tags'**
  String get tagsSelect;

  /// No description provided for @tagsNoTags.
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get tagsNoTags;

  /// No description provided for @tagsCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Tag'**
  String get tagsCreate;

  /// No description provided for @tagsCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create new tag'**
  String get tagsCreateNew;

  /// No description provided for @tagsEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter tag name'**
  String get tagsEnterName;

  /// No description provided for @tagsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search tags...'**
  String get tagsSearch;

  /// No description provided for @tagsSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested Tags'**
  String get tagsSuggested;

  /// No description provided for @tagsRecent.
  ///
  /// In en, this message translates to:
  /// **'Recently Used'**
  String get tagsRecent;

  /// No description provided for @tagsAll.
  ///
  /// In en, this message translates to:
  /// **'All Tags'**
  String get tagsAll;

  /// No description provided for @tagVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get tagVegetarian;

  /// No description provided for @tagVegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get tagVegan;

  /// No description provided for @tagGlutenFree.
  ///
  /// In en, this message translates to:
  /// **'Gluten-Free'**
  String get tagGlutenFree;

  /// No description provided for @tagDairyFree.
  ///
  /// In en, this message translates to:
  /// **'Dairy-Free'**
  String get tagDairyFree;

  /// No description provided for @tagNutFree.
  ///
  /// In en, this message translates to:
  /// **'Nut-Free'**
  String get tagNutFree;

  /// No description provided for @tagLowCarb.
  ///
  /// In en, this message translates to:
  /// **'Low Carb'**
  String get tagLowCarb;

  /// No description provided for @tagKeto.
  ///
  /// In en, this message translates to:
  /// **'Keto'**
  String get tagKeto;

  /// No description provided for @tagPaleo.
  ///
  /// In en, this message translates to:
  /// **'Paleo'**
  String get tagPaleo;

  /// No description provided for @tagWhole30.
  ///
  /// In en, this message translates to:
  /// **'Whole30'**
  String get tagWhole30;

  /// No description provided for @tagQuick.
  ///
  /// In en, this message translates to:
  /// **'Quick'**
  String get tagQuick;

  /// No description provided for @tagEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get tagEasy;

  /// No description provided for @tagHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get tagHealthy;

  /// No description provided for @tagComfortFood.
  ///
  /// In en, this message translates to:
  /// **'Comfort Food'**
  String get tagComfortFood;

  /// No description provided for @tagFamilyFriendly.
  ///
  /// In en, this message translates to:
  /// **'Family Friendly'**
  String get tagFamilyFriendly;

  /// No description provided for @tagKidFriendly.
  ///
  /// In en, this message translates to:
  /// **'Kid Friendly'**
  String get tagKidFriendly;

  /// No description provided for @tagMealPrep.
  ///
  /// In en, this message translates to:
  /// **'Meal Prep'**
  String get tagMealPrep;

  /// No description provided for @tagOnePot.
  ///
  /// In en, this message translates to:
  /// **'One Pot'**
  String get tagOnePot;

  /// No description provided for @tagInstantPot.
  ///
  /// In en, this message translates to:
  /// **'Instant Pot'**
  String get tagInstantPot;

  /// No description provided for @tagSlowCooker.
  ///
  /// In en, this message translates to:
  /// **'Slow Cooker'**
  String get tagSlowCooker;

  /// No description provided for @tagAirFryer.
  ///
  /// In en, this message translates to:
  /// **'Air Fryer'**
  String get tagAirFryer;

  /// No description provided for @tagGrill.
  ///
  /// In en, this message translates to:
  /// **'Grill'**
  String get tagGrill;

  /// No description provided for @tagBBQ.
  ///
  /// In en, this message translates to:
  /// **'BBQ'**
  String get tagBBQ;

  /// No description provided for @tagHoliday.
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get tagHoliday;

  /// No description provided for @tagParty.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get tagParty;

  /// No description provided for @tagBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get tagBudget;

  /// No description provided for @tagSpicy.
  ///
  /// In en, this message translates to:
  /// **'Spicy'**
  String get tagSpicy;

  /// No description provided for @tagSweet.
  ///
  /// In en, this message translates to:
  /// **'Sweet'**
  String get tagSweet;

  /// No description provided for @tagSavory.
  ///
  /// In en, this message translates to:
  /// **'Savory'**
  String get tagSavory;

  /// No description provided for @tagLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get tagLight;

  /// No description provided for @tagHearty.
  ///
  /// In en, this message translates to:
  /// **'Hearty'**
  String get tagHearty;

  /// No description provided for @tagSummer.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get tagSummer;

  /// No description provided for @tagWinter.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get tagWinter;

  /// No description provided for @tagFall.
  ///
  /// In en, this message translates to:
  /// **'Fall'**
  String get tagFall;

  /// No description provided for @tagSpring.
  ///
  /// In en, this message translates to:
  /// **'Spring'**
  String get tagSpring;

  /// No description provided for @settingsImagePlaceholders.
  ///
  /// In en, this message translates to:
  /// **'Image Placeholders'**
  String get settingsImagePlaceholders;

  /// No description provided for @settingsImagePlaceholdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose what shows when images are missing'**
  String get settingsImagePlaceholdersSubtitle;

  /// No description provided for @settingsQuickAccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure what appears in Quick Access'**
  String get settingsQuickAccessSubtitle;

  /// No description provided for @settingsManageCoursesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add, edit, or remove courses'**
  String get settingsManageCoursesSubtitle;

  /// No description provided for @settingsManageCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add, edit, or remove categories'**
  String get settingsManageCategoriesSubtitle;

  /// No description provided for @settingsShoppingCategories.
  ///
  /// In en, this message translates to:
  /// **'Shopping Categories'**
  String get settingsShoppingCategories;

  /// No description provided for @settingsShoppingCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize items by aisle'**
  String get settingsShoppingCategoriesSubtitle;

  /// No description provided for @shoppingIngredientMappings.
  ///
  /// In en, this message translates to:
  /// **'Ingredient Mappings'**
  String get shoppingIngredientMappings;

  /// No description provided for @shoppingPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority: {priority}'**
  String shoppingPriority(int priority);

  /// No description provided for @shoppingAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get shoppingAddCategory;

  /// No description provided for @shoppingEditCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get shoppingEditCategory;

  /// No description provided for @shoppingDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category?'**
  String get shoppingDeleteCategory;

  /// No description provided for @shoppingDeleteCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? Items in this category will become uncategorized.'**
  String shoppingDeleteCategoryMessage(String name);

  /// No description provided for @shoppingCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get shoppingCategoryName;

  /// No description provided for @shoppingSearchIngredients.
  ///
  /// In en, this message translates to:
  /// **'Search ingredients...'**
  String get shoppingSearchIngredients;

  /// No description provided for @shoppingMappingsInfo.
  ///
  /// In en, this message translates to:
  /// **'Tap the category to change where an ingredient goes. ({count} mappings)'**
  String shoppingMappingsInfo(int count);

  /// No description provided for @shoppingCategoryFor.
  ///
  /// In en, this message translates to:
  /// **'Category for \"{ingredient}\"'**
  String shoppingCategoryFor(String ingredient);

  /// No description provided for @shoppingMovedTo.
  ///
  /// In en, this message translates to:
  /// **'\"{ingredient}\" moved to {category}'**
  String shoppingMovedTo(String ingredient, String category);

  /// No description provided for @shoppingResetToDefault.
  ///
  /// In en, this message translates to:
  /// **'\"{ingredient}\" reset to default'**
  String shoppingResetToDefault(String ingredient);

  /// No description provided for @actionReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get actionReset;

  /// No description provided for @shoppingMappingMoved.
  ///
  /// In en, this message translates to:
  /// **'\"{ingredient}\" moved to {category}'**
  String shoppingMappingMoved(String ingredient, String category);

  /// No description provided for @shoppingMappingReset.
  ///
  /// In en, this message translates to:
  /// **'\"{ingredient}\" reset to default'**
  String shoppingMappingReset(String ingredient);

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @addPhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to select from gallery or camera'**
  String get addPhotoSubtitle;

  /// No description provided for @viewAllRecipes.
  ///
  /// In en, this message translates to:
  /// **'View All Recipes'**
  String get viewAllRecipes;

  /// No description provided for @recipesTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} recipes total'**
  String recipesTotal(int count);

  /// No description provided for @coursesTitle.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get coursesTitle;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @courseBrunch.
  ///
  /// In en, this message translates to:
  /// **'Brunch'**
  String get courseBrunch;

  /// No description provided for @courseMainDish.
  ///
  /// In en, this message translates to:
  /// **'Main Dish'**
  String get courseMainDish;

  /// No description provided for @courseSideDish.
  ///
  /// In en, this message translates to:
  /// **'Side Dish'**
  String get courseSideDish;

  /// No description provided for @courseSauce.
  ///
  /// In en, this message translates to:
  /// **'Sauce'**
  String get courseSauce;

  /// No description provided for @courseBread.
  ///
  /// In en, this message translates to:
  /// **'Bread'**
  String get courseBread;

  /// No description provided for @categoryBean.
  ///
  /// In en, this message translates to:
  /// **'Bean'**
  String get categoryBean;

  /// No description provided for @categoryBread.
  ///
  /// In en, this message translates to:
  /// **'Bread'**
  String get categoryBread;

  /// No description provided for @categoryBurritoTaco.
  ///
  /// In en, this message translates to:
  /// **'Burrito/Taco'**
  String get categoryBurritoTaco;

  /// No description provided for @categoryCasserole.
  ///
  /// In en, this message translates to:
  /// **'Casserole'**
  String get categoryCasserole;

  /// No description provided for @categoryChickenSteakMeat.
  ///
  /// In en, this message translates to:
  /// **'Chicken/Steak/Meat'**
  String get categoryChickenSteakMeat;

  /// No description provided for @categoryDessert.
  ///
  /// In en, this message translates to:
  /// **'Dessert'**
  String get categoryDessert;

  /// No description provided for @categoryFish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get categoryFish;

  /// No description provided for @categoryFruit.
  ///
  /// In en, this message translates to:
  /// **'Fruit'**
  String get categoryFruit;

  /// No description provided for @categoryPasta.
  ///
  /// In en, this message translates to:
  /// **'Pasta'**
  String get categoryPasta;

  /// No description provided for @categoryPizza.
  ///
  /// In en, this message translates to:
  /// **'Pizza'**
  String get categoryPizza;

  /// No description provided for @categoryPork.
  ///
  /// In en, this message translates to:
  /// **'Pork'**
  String get categoryPork;

  /// No description provided for @categoryRice.
  ///
  /// In en, this message translates to:
  /// **'Rice'**
  String get categoryRice;

  /// No description provided for @categorySandwich.
  ///
  /// In en, this message translates to:
  /// **'Sandwich'**
  String get categorySandwich;

  /// No description provided for @categorySeafood.
  ///
  /// In en, this message translates to:
  /// **'Seafood'**
  String get categorySeafood;

  /// No description provided for @categorySoup.
  ///
  /// In en, this message translates to:
  /// **'Soup'**
  String get categorySoup;

  /// No description provided for @categoryVegetable.
  ///
  /// In en, this message translates to:
  /// **'Vegetable'**
  String get categoryVegetable;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @wordOf.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get wordOf;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get more;

  /// No description provided for @less.
  ///
  /// In en, this message translates to:
  /// **'less'**
  String get less;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @defaultValue.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultValue;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @photoChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get photoChooseGallery;

  /// No description provided for @importFirstRecipe.
  ///
  /// In en, this message translates to:
  /// **'Import First'**
  String get importFirstRecipe;

  /// No description provided for @importAllRecipes.
  ///
  /// In en, this message translates to:
  /// **'Import All'**
  String get importAllRecipes;

  /// No description provided for @parseRecipe.
  ///
  /// In en, this message translates to:
  /// **'Parse Recipe'**
  String get parseRecipe;

  /// No description provided for @shareRecipe.
  ///
  /// In en, this message translates to:
  /// **'Share Recipe'**
  String get shareRecipe;

  /// No description provided for @shareExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get shareExport;

  /// No description provided for @shareServings.
  ///
  /// In en, this message translates to:
  /// **'Servings: {count}'**
  String shareServings(int count);

  /// No description provided for @sharePrep.
  ///
  /// In en, this message translates to:
  /// **'Prep: {minutes} min'**
  String sharePrep(int minutes);

  /// No description provided for @shareCook.
  ///
  /// In en, this message translates to:
  /// **'Cook: {minutes} min'**
  String shareCook(int minutes);

  /// No description provided for @shareFromApp.
  ///
  /// In en, this message translates to:
  /// **'Shared from Recipe Spellbook'**
  String get shareFromApp;

  /// No description provided for @shareCreatingCard.
  ///
  /// In en, this message translates to:
  /// **'Creating recipe card...'**
  String get shareCreatingCard;

  /// No description provided for @shareCheckRecipe.
  ///
  /// In en, this message translates to:
  /// **'Check out this recipe: {title}'**
  String shareCheckRecipe(String title);

  /// No description provided for @shareErrorImage.
  ///
  /// In en, this message translates to:
  /// **'Error creating image: {error}'**
  String shareErrorImage(String error);

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItem;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @selectNone.
  ///
  /// In en, this message translates to:
  /// **'Select None'**
  String get selectNone;

  /// No description provided for @viewPlanner.
  ///
  /// In en, this message translates to:
  /// **'View Planner'**
  String get viewPlanner;

  /// No description provided for @planNow.
  ///
  /// In en, this message translates to:
  /// **'Plan Now'**
  String get planNow;

  /// No description provided for @loadingText.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingText;

  /// No description provided for @errorText.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorText;

  /// No description provided for @errorLoadingMeals.
  ///
  /// In en, this message translates to:
  /// **'Error loading meals'**
  String get errorLoadingMeals;

  /// No description provided for @readingImage.
  ///
  /// In en, this message translates to:
  /// **'Reading image...'**
  String get readingImage;

  /// No description provided for @parsingRecipe.
  ///
  /// In en, this message translates to:
  /// **'Parsing recipe...'**
  String get parsingRecipe;

  /// No description provided for @noTextInImage.
  ///
  /// In en, this message translates to:
  /// **'No text found in image'**
  String get noTextInImage;

  /// No description provided for @failedProcessImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to process image: {error}'**
  String failedProcessImage(String error);

  /// No description provided for @cookingModeExit.
  ///
  /// In en, this message translates to:
  /// **'Exit Cooking Mode'**
  String get cookingModeExit;

  /// No description provided for @cookingModeStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String cookingModeStep(int current, int total);

  /// No description provided for @cookingModePrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get cookingModePrevious;

  /// No description provided for @cookingModeNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get cookingModeNext;

  /// No description provided for @cookingModeFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get cookingModeFinish;

  /// No description provided for @cookingModeCompleted.
  ///
  /// In en, this message translates to:
  /// **'Recipe Completed!'**
  String get cookingModeCompleted;

  /// No description provided for @cookingModeGreatJob.
  ///
  /// In en, this message translates to:
  /// **'Great job! Enjoy your meal.'**
  String get cookingModeGreatJob;

  /// No description provided for @mealPlanBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealPlanBreakfast;

  /// No description provided for @mealPlanLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealPlanLunch;

  /// No description provided for @mealPlanDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealPlanDinner;

  /// No description provided for @mealPlanSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get mealPlanSnack;

  /// No description provided for @mealPlanAddMeal.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get mealPlanAddMeal;

  /// No description provided for @mealPlanRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from Plan'**
  String get mealPlanRemove;

  /// No description provided for @mealPlanNoMeals.
  ///
  /// In en, this message translates to:
  /// **'No meals planned'**
  String get mealPlanNoMeals;

  /// No description provided for @mealPlanTapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a meal'**
  String get mealPlanTapToAdd;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get itemName;

  /// No description provided for @addToShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Add to Shopping List'**
  String get addToShoppingList;

  /// No description provided for @addToList.
  ///
  /// In en, this message translates to:
  /// **'Add to list'**
  String get addToList;

  /// No description provided for @addedItemsToList.
  ///
  /// In en, this message translates to:
  /// **'Added {count} items to shopping list'**
  String addedItemsToList(int count);

  /// No description provided for @scanToImport.
  ///
  /// In en, this message translates to:
  /// **'Scan to import recipe'**
  String get scanToImport;

  /// No description provided for @xOfY.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String xOfY(int current, int total);

  /// No description provided for @addItems.
  ///
  /// In en, this message translates to:
  /// **'Add {count} Items'**
  String addItems(int count);

  /// No description provided for @failedToParse.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse: {error}'**
  String failedToParse(String error);

  /// No description provided for @failedToImport.
  ///
  /// In en, this message translates to:
  /// **'Failed to import: {error}'**
  String failedToImport(String error);

  /// No description provided for @groupBy.
  ///
  /// In en, this message translates to:
  /// **'Group by'**
  String get groupBy;

  /// No description provided for @cookbookHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to select • Long press to edit'**
  String get cookbookHint;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @renameCookbook.
  ///
  /// In en, this message translates to:
  /// **'Rename Cookbook'**
  String get renameCookbook;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @imagePlaceholders.
  ///
  /// In en, this message translates to:
  /// **'Image Placeholders'**
  String get imagePlaceholders;

  /// No description provided for @imagePlaceholdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose what shows when images are missing'**
  String get imagePlaceholdersSubtitle;

  /// No description provided for @homeScreenSection.
  ///
  /// In en, this message translates to:
  /// **'Home Screen'**
  String get homeScreenSection;

  /// No description provided for @quickAccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure what appears in Quick Access'**
  String get quickAccessSubtitle;

  /// No description provided for @manageCoursesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add, edit, or remove courses'**
  String get manageCoursesSubtitle;

  /// No description provided for @manageCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add, edit, or remove categories'**
  String get manageCategoriesSubtitle;

  /// No description provided for @shoppingCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize items by aisle'**
  String get shoppingCategoriesSubtitle;

  /// No description provided for @syncSection.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncSection;

  /// No description provided for @cloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get cloudSync;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @resetApp.
  ///
  /// In en, this message translates to:
  /// **'Reset App'**
  String get resetApp;

  /// No description provided for @resetAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data permanently'**
  String get resetAppSubtitle;

  /// No description provided for @trashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deleted recipes (30-day retention)'**
  String get trashSubtitle;

  /// No description provided for @importRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Recipe'**
  String get importRecipeTitle;

  /// No description provided for @importSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Import your recipes from any social media platform or website.'**
  String get importSocialMedia;

  /// No description provided for @pasteRecipeUrl.
  ///
  /// In en, this message translates to:
  /// **'Paste recipe URL'**
  String get pasteRecipeUrl;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orDivider;

  /// No description provided for @fileOption.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get fileOption;

  /// No description provided for @imageOption.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get imageOption;

  /// No description provided for @pasteOption.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get pasteOption;

  /// No description provided for @supportedFormats.
  ///
  /// In en, this message translates to:
  /// **'Supports Paprika, Mela, JSON, ZIP exports'**
  String get supportedFormats;

  /// No description provided for @pasteRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Paste Recipe'**
  String get pasteRecipeTitle;

  /// No description provided for @pasteRecipeHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your recipe here...'**
  String get pasteRecipeHint;

  /// No description provided for @quickAccessHelpIntro.
  ///
  /// In en, this message translates to:
  /// **'These badges indicate why recipes appear here:'**
  String get quickAccessHelpIntro;

  /// No description provided for @quickAccessHelpMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Scheduled for today'**
  String get quickAccessHelpMealPlan;

  /// No description provided for @quickAccessHelpPinned.
  ///
  /// In en, this message translates to:
  /// **'You\'ve pinned this recipe'**
  String get quickAccessHelpPinned;

  /// No description provided for @quickAccessHelpRecent.
  ///
  /// In en, this message translates to:
  /// **'Recently viewed'**
  String get quickAccessHelpRecent;

  /// No description provided for @openCalendar.
  ///
  /// In en, this message translates to:
  /// **'Open calendar'**
  String get openCalendar;

  /// No description provided for @editNotes.
  ///
  /// In en, this message translates to:
  /// **'Edit notes'**
  String get editNotes;

  /// No description provided for @addNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add notes...'**
  String get addNotesHint;

  /// No description provided for @moveToAnotherDay.
  ///
  /// In en, this message translates to:
  /// **'Move to another day'**
  String get moveToAnotherDay;

  /// No description provided for @addToPlan.
  ///
  /// In en, this message translates to:
  /// **'Add to Plan'**
  String get addToPlan;

  /// No description provided for @importBulkQuestion.
  ///
  /// In en, this message translates to:
  /// **'Would you like to import all {count} recipes or select individually?'**
  String importBulkQuestion(int count);

  /// No description provided for @importingRecipes.
  ///
  /// In en, this message translates to:
  /// **'Importing recipes...'**
  String get importingRecipes;

  /// No description provided for @importedRecipesCount.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} recipes'**
  String importedRecipesCount(int count);

  /// No description provided for @extractingArchive.
  ///
  /// In en, this message translates to:
  /// **'Extracting archive...'**
  String get extractingArchive;

  /// No description provided for @themeSpellbook.
  ///
  /// In en, this message translates to:
  /// **'Spellbook'**
  String get themeSpellbook;

  /// No description provided for @themeForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get themeForest;

  /// No description provided for @themeOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get themeOcean;

  /// No description provided for @themeSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get themeSunset;

  /// No description provided for @themeMidnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get themeMidnight;

  /// No description provided for @themeRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get themeRose;

  /// No description provided for @colorTheme.
  ///
  /// In en, this message translates to:
  /// **'Color Theme'**
  String get colorTheme;

  /// No description provided for @colorThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your app\'s color palette'**
  String get colorThemeSubtitle;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @previewPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get previewPrimary;

  /// No description provided for @previewSecondary.
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get previewSecondary;

  /// No description provided for @previewTertiary.
  ///
  /// In en, this message translates to:
  /// **'Tertiary'**
  String get previewTertiary;

  /// No description provided for @previewError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get previewError;

  /// No description provided for @placeholderDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose what to display when recipes or cookbooks don\'t have images.'**
  String get placeholderDescription;

  /// No description provided for @recipePlaceholders.
  ///
  /// In en, this message translates to:
  /// **'Recipe Placeholders'**
  String get recipePlaceholders;

  /// No description provided for @cookbookPlaceholders.
  ///
  /// In en, this message translates to:
  /// **'Cookbook Placeholders'**
  String get cookbookPlaceholders;

  /// No description provided for @defaultImages.
  ///
  /// In en, this message translates to:
  /// **'Default Images'**
  String get defaultImages;

  /// No description provided for @defaultImagesDescription.
  ///
  /// In en, this message translates to:
  /// **'Default app artwork for recipes and cookbooks'**
  String get defaultImagesDescription;

  /// No description provided for @themeBased.
  ///
  /// In en, this message translates to:
  /// **'Theme-based'**
  String get themeBased;

  /// No description provided for @themeBasedDescription.
  ///
  /// In en, this message translates to:
  /// **'Gradient with logo based on your color theme'**
  String get themeBasedDescription;

  /// No description provided for @groupBySection.
  ///
  /// In en, this message translates to:
  /// **'By Section'**
  String get groupBySection;

  /// No description provided for @groupByRecipe.
  ///
  /// In en, this message translates to:
  /// **'By Recipe'**
  String get groupByRecipe;

  /// No description provided for @groupByUngrouped.
  ///
  /// In en, this message translates to:
  /// **'Ungrouped'**
  String get groupByUngrouped;

  /// No description provided for @copyAsText.
  ///
  /// In en, this message translates to:
  /// **'Copy as Text'**
  String get copyAsText;

  /// No description provided for @printList.
  ///
  /// In en, this message translates to:
  /// **'Print List'**
  String get printList;

  /// No description provided for @manageLists.
  ///
  /// In en, this message translates to:
  /// **'Manage Lists'**
  String get manageLists;

  /// No description provided for @newList.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newList;

  /// No description provided for @newShoppingList.
  ///
  /// In en, this message translates to:
  /// **'New Shopping List'**
  String get newShoppingList;

  /// No description provided for @listNameHint.
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get listNameHint;

  /// No description provided for @recipeLayoutSetting.
  ///
  /// In en, this message translates to:
  /// **'Recipe Layout'**
  String get recipeLayoutSetting;

  /// No description provided for @recipeLayoutSettingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how recipe details are displayed'**
  String get recipeLayoutSettingSubtitle;

  /// No description provided for @layoutTabbedOption.
  ///
  /// In en, this message translates to:
  /// **'Tabbed View'**
  String get layoutTabbedOption;

  /// No description provided for @layoutStackedOption.
  ///
  /// In en, this message translates to:
  /// **'Stacked View'**
  String get layoutStackedOption;

  /// No description provided for @nutrientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrientsTitle;

  /// No description provided for @nutrientsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nutritional information per serving'**
  String get nutrientsSubtitle;

  /// No description provided for @addNutrients.
  ///
  /// In en, this message translates to:
  /// **'Add Nutrition Info'**
  String get addNutrients;

  /// No description provided for @calculateNutrients.
  ///
  /// In en, this message translates to:
  /// **'Calculate from Ingredients'**
  String get calculateNutrients;

  /// No description provided for @nutrientsDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Nutritional values are estimates. Accuracy depends on ingredient measurements. Using a food scale with gram measurements provides the best accuracy.'**
  String get nutrientsDisclaimer;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @carbohydrates.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbohydrates;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @fiber.
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get fiber;

  /// No description provided for @sugar.
  ///
  /// In en, this message translates to:
  /// **'Sugar'**
  String get sugar;

  /// No description provided for @sodium.
  ///
  /// In en, this message translates to:
  /// **'Sodium'**
  String get sodium;

  /// No description provided for @cholesterol.
  ///
  /// In en, this message translates to:
  /// **'Cholesterol'**
  String get cholesterol;

  /// No description provided for @saturatedFat.
  ///
  /// In en, this message translates to:
  /// **'Saturated Fat'**
  String get saturatedFat;

  /// No description provided for @transFat.
  ///
  /// In en, this message translates to:
  /// **'Trans Fat'**
  String get transFat;

  /// No description provided for @servingSize.
  ///
  /// In en, this message translates to:
  /// **'Serving Size'**
  String get servingSize;

  /// No description provided for @perServing.
  ///
  /// In en, this message translates to:
  /// **'Per Serving'**
  String get perServing;

  /// No description provided for @calculatingNutrients.
  ///
  /// In en, this message translates to:
  /// **'Calculating nutrition...'**
  String get calculatingNutrients;

  /// No description provided for @nutrientsCalculated.
  ///
  /// In en, this message translates to:
  /// **'Nutrition calculated'**
  String get nutrientsCalculated;

  /// No description provided for @nutrientsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not calculate nutrition: {error}'**
  String nutrientsFailed(String error);

  /// No description provided for @premiumFeature.
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get premiumFeature;

  /// No description provided for @premiumNutrientsDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatic nutrition calculation requires a premium subscription'**
  String get premiumNutrientsDescription;

  /// No description provided for @exportCurrentCookbook.
  ///
  /// In en, this message translates to:
  /// **'Export Current Cookbook'**
  String get exportCurrentCookbook;

  /// No description provided for @exporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting...'**
  String get exporting;

  /// No description provided for @exportAllCookbooks.
  ///
  /// In en, this message translates to:
  /// **'Export All Cookbooks'**
  String get exportAllCookbooks;

  /// No description provided for @importing.
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get importing;

  /// No description provided for @importFromJson.
  ///
  /// In en, this message translates to:
  /// **'Import from JSON'**
  String get importFromJson;

  /// No description provided for @importFromJsonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a backup file'**
  String get importFromJsonSubtitle;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Your magical recipe companion for organizing, planning, and cooking delicious meals.'**
  String get aboutDescription;

  /// No description provided for @madeWithLove.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ for home cooks everywhere'**
  String get madeWithLove;

  /// No description provided for @resetAppWarning.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your recipes, meal plans, shopping lists, and settings. This cannot be undone.'**
  String get resetAppWarning;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @finalConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Final Confirmation'**
  String get finalConfirmation;

  /// No description provided for @typeDeleteToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm'**
  String get typeDeleteToConfirm;

  /// No description provided for @typeDeleteHint.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get typeDeleteHint;

  /// No description provided for @resetScopeLocal.
  ///
  /// In en, this message translates to:
  /// **'local data'**
  String get resetScopeLocal;

  /// No description provided for @resetScopeCloud.
  ///
  /// In en, this message translates to:
  /// **'cloud data'**
  String get resetScopeCloud;

  /// No description provided for @resetScopeAll.
  ///
  /// In en, this message translates to:
  /// **'all data, cloud sync, and your account'**
  String get resetScopeAll;

  /// No description provided for @resetEverything.
  ///
  /// In en, this message translates to:
  /// **'Reset Everything'**
  String get resetEverything;

  /// No description provided for @resettingApp.
  ///
  /// In en, this message translates to:
  /// **'Resetting app...'**
  String get resettingApp;

  /// No description provided for @appResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'App reset successfully'**
  String get appResetSuccess;

  /// No description provided for @resetFailed.
  ///
  /// In en, this message translates to:
  /// **'Reset failed'**
  String get resetFailed;

  /// No description provided for @successAdded.
  ///
  /// In en, this message translates to:
  /// **'Added successfully'**
  String get successAdded;

  /// No description provided for @selectToday.
  ///
  /// In en, this message translates to:
  /// **'Select Today'**
  String get selectToday;

  /// No description provided for @selectTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Select Tomorrow'**
  String get selectTomorrow;

  /// No description provided for @addedManually.
  ///
  /// In en, this message translates to:
  /// **'Added Manually'**
  String get addedManually;

  /// No description provided for @unknownRecipe.
  ///
  /// In en, this message translates to:
  /// **'Unknown Recipe'**
  String get unknownRecipe;

  /// No description provided for @shoppingListEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your shopping list is empty'**
  String get shoppingListEmpty;

  /// No description provided for @shoppingListEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add items or import from recipes'**
  String get shoppingListEmptyHint;

  /// No description provided for @settingsKitchenBuddyActive.
  ///
  /// In en, this message translates to:
  /// **'Your Kitchen Buddy is ready to cook!'**
  String get settingsKitchenBuddyActive;

  /// No description provided for @shoppingCheckAll.
  ///
  /// In en, this message translates to:
  /// **'Check All'**
  String get shoppingCheckAll;

  /// No description provided for @shoppingUncheckAll.
  ///
  /// In en, this message translates to:
  /// **'Uncheck All'**
  String get shoppingUncheckAll;

  /// No description provided for @shoppingManageLists.
  ///
  /// In en, this message translates to:
  /// **'Manage Lists'**
  String get shoppingManageLists;

  /// No description provided for @shoppingNewList.
  ///
  /// In en, this message translates to:
  /// **'New Shopping List'**
  String get shoppingNewList;

  /// No description provided for @shoppingListName.
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get shoppingListName;

  /// No description provided for @shoppingLists.
  ///
  /// In en, this message translates to:
  /// **'Shopping Lists'**
  String get shoppingLists;

  /// No description provided for @shoppingRenameList.
  ///
  /// In en, this message translates to:
  /// **'Rename List'**
  String get shoppingRenameList;

  /// No description provided for @shoppingDeleteList.
  ///
  /// In en, this message translates to:
  /// **'Delete List?'**
  String get shoppingDeleteList;

  /// No description provided for @categoryProduce.
  ///
  /// In en, this message translates to:
  /// **'Produce'**
  String get categoryProduce;

  /// No description provided for @categoryDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get categoryDairy;

  /// No description provided for @categoryMeat.
  ///
  /// In en, this message translates to:
  /// **'Meat'**
  String get categoryMeat;

  /// No description provided for @categoryBakery.
  ///
  /// In en, this message translates to:
  /// **'Bakery'**
  String get categoryBakery;

  /// No description provided for @categoryFrozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get categoryFrozen;

  /// No description provided for @categoryBeverages.
  ///
  /// In en, this message translates to:
  /// **'Beverages'**
  String get categoryBeverages;

  /// No description provided for @categoryPantry.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get categoryPantry;

  /// No description provided for @categorySpices.
  ///
  /// In en, this message translates to:
  /// **'Spices'**
  String get categorySpices;

  /// No description provided for @categoryInternational.
  ///
  /// In en, this message translates to:
  /// **'International'**
  String get categoryInternational;

  /// No description provided for @categorySnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get categorySnacks;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get from;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'deleted'**
  String get deleted;

  /// No description provided for @currently.
  ///
  /// In en, this message translates to:
  /// **'Currently in'**
  String get currently;

  /// No description provided for @autoDetect.
  ///
  /// In en, this message translates to:
  /// **'Auto-detect'**
  String get autoDetect;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @actionNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get actionNew;

  /// No description provided for @actionCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get actionCreate;

  /// No description provided for @tagsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Tag'**
  String get tagsAdd;

  /// No description provided for @tagsSearchOrCreate.
  ///
  /// In en, this message translates to:
  /// **'Search or create tag...'**
  String get tagsSearchOrCreate;

  /// No description provided for @tagsNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching tags found'**
  String get tagsNoResults;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @nutritionTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutritionTitle;

  /// No description provided for @nutritionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No nutrition data'**
  String get nutritionEmpty;

  /// No description provided for @nutritionEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Edit this recipe and calculate nutrition from ingredients'**
  String get nutritionEmptyHint;

  /// No description provided for @scaled.
  ///
  /// In en, this message translates to:
  /// **'scaled'**
  String get scaled;

  /// No description provided for @nutritionCalculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate Nutrition'**
  String get nutritionCalculate;

  /// No description provided for @nutritionCalculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating nutrition...'**
  String get nutritionCalculating;

  /// No description provided for @nutritionMatchingIngredients.
  ///
  /// In en, this message translates to:
  /// **'Matching ingredients to USDA database'**
  String get nutritionMatchingIngredients;

  /// No description provided for @nutritionCalculationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not calculate nutrition'**
  String get nutritionCalculationFailed;

  /// No description provided for @nutritionDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Nutrition values are estimates based on USDA data. Actual values may vary depending on specific products, preparation methods, and portion sizes.'**
  String get nutritionDisclaimer;

  /// No description provided for @nutritionPerServing.
  ///
  /// In en, this message translates to:
  /// **'Per Serving'**
  String get nutritionPerServing;

  /// No description provided for @nutritionServings.
  ///
  /// In en, this message translates to:
  /// **'{count} servings'**
  String nutritionServings(int count);

  /// No description provided for @nutritionIngredientBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Ingredient Breakdown'**
  String get nutritionIngredientBreakdown;

  /// No description provided for @nutritionIngredientsMatched.
  ///
  /// In en, this message translates to:
  /// **'Ingredients Matched'**
  String get nutritionIngredientsMatched;

  /// No description provided for @nutritionMatchedCount.
  ///
  /// In en, this message translates to:
  /// **'{matched} of {total} matched'**
  String nutritionMatchedCount(int matched, int total);

  /// No description provided for @nutritionUncertainCount.
  ///
  /// In en, this message translates to:
  /// **'{count} need review'**
  String nutritionUncertainCount(int count);

  /// No description provided for @nutritionUncertain.
  ///
  /// In en, this message translates to:
  /// **'verify match'**
  String get nutritionUncertain;

  /// No description provided for @nutritionNotFound.
  ///
  /// In en, this message translates to:
  /// **'No match found - tap to search'**
  String get nutritionNotFound;

  /// No description provided for @nutritionRecalculate.
  ///
  /// In en, this message translates to:
  /// **'Recalculate'**
  String get nutritionRecalculate;

  /// No description provided for @nutritionOverwriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Overwrite Nutrition Data?'**
  String get nutritionOverwriteTitle;

  /// No description provided for @nutritionOverwriteMessage.
  ///
  /// In en, this message translates to:
  /// **'This recipe already has nutrition data. Do you want to recalculate and replace it with new values?'**
  String get nutritionOverwriteMessage;

  /// No description provided for @nutritionCalculated.
  ///
  /// In en, this message translates to:
  /// **'Nutrition calculated successfully'**
  String get nutritionCalculated;

  /// No description provided for @nutritionSave.
  ///
  /// In en, this message translates to:
  /// **'Save Nutrition'**
  String get nutritionSave;

  /// No description provided for @nutritionSelectFood.
  ///
  /// In en, this message translates to:
  /// **'Select USDA Food'**
  String get nutritionSelectFood;

  /// No description provided for @nutritionSearchFood.
  ///
  /// In en, this message translates to:
  /// **'Search foods...'**
  String get nutritionSearchFood;

  /// No description provided for @nutritionNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get nutritionNoResults;

  /// No description provided for @nutritionCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get nutritionCalories;

  /// No description provided for @nutritionProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get nutritionProtein;

  /// No description provided for @nutritionCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get nutritionCarbs;

  /// No description provided for @nutritionFat.
  ///
  /// In en, this message translates to:
  /// **'Total Fat'**
  String get nutritionFat;

  /// No description provided for @nutritionSaturatedFat.
  ///
  /// In en, this message translates to:
  /// **'Saturated Fat'**
  String get nutritionSaturatedFat;

  /// No description provided for @nutritionTransFat.
  ///
  /// In en, this message translates to:
  /// **'Trans Fat'**
  String get nutritionTransFat;

  /// No description provided for @nutritionFiber.
  ///
  /// In en, this message translates to:
  /// **'Dietary Fiber'**
  String get nutritionFiber;

  /// No description provided for @nutritionSugar.
  ///
  /// In en, this message translates to:
  /// **'Sugars'**
  String get nutritionSugar;

  /// No description provided for @nutritionCholesterol.
  ///
  /// In en, this message translates to:
  /// **'Cholesterol'**
  String get nutritionCholesterol;

  /// No description provided for @nutritionSodium.
  ///
  /// In en, this message translates to:
  /// **'Sodium'**
  String get nutritionSodium;

  /// No description provided for @nutritionPotassium.
  ///
  /// In en, this message translates to:
  /// **'Potassium'**
  String get nutritionPotassium;

  /// No description provided for @nutritionCalcium.
  ///
  /// In en, this message translates to:
  /// **'Calcium'**
  String get nutritionCalcium;

  /// No description provided for @nutritionIron.
  ///
  /// In en, this message translates to:
  /// **'Iron'**
  String get nutritionIron;

  /// No description provided for @nutritionVitaminA.
  ///
  /// In en, this message translates to:
  /// **'Vitamin A'**
  String get nutritionVitaminA;

  /// No description provided for @nutritionVitaminC.
  ///
  /// In en, this message translates to:
  /// **'Vitamin C'**
  String get nutritionVitaminC;

  /// No description provided for @nutritionVitaminD.
  ///
  /// In en, this message translates to:
  /// **'Vitamin D'**
  String get nutritionVitaminD;

  /// No description provided for @layoutInfoText.
  ///
  /// In en, this message translates to:
  /// **'Nutrition data (if calculated) will appear in both layouts. Tabbed layout allows swiping between sections.'**
  String get layoutInfoText;

  /// No description provided for @settingsManageTagsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create and organize recipe tags'**
  String get settingsManageTagsSubtitle;

  /// No description provided for @nutritionTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get nutritionTotal;

  /// No description provided for @nutritionAutoCalculate.
  ///
  /// In en, this message translates to:
  /// **'Auto-Calculate'**
  String get nutritionAutoCalculate;

  /// No description provided for @nutritionManualEntry.
  ///
  /// In en, this message translates to:
  /// **'Enter Manually'**
  String get nutritionManualEntry;

  /// No description provided for @nutritionManualEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Known Values'**
  String get nutritionManualEntryTitle;

  /// No description provided for @nutritionManualEntryDescription.
  ///
  /// In en, this message translates to:
  /// **'If you know the exact nutrition values (from packaging, website, etc.), enter them here.'**
  String get nutritionManualEntryDescription;

  /// No description provided for @nutritionMainNutrients.
  ///
  /// In en, this message translates to:
  /// **'Main Nutrients'**
  String get nutritionMainNutrients;

  /// No description provided for @nutritionOtherNutrients.
  ///
  /// In en, this message translates to:
  /// **'Other Nutrients'**
  String get nutritionOtherNutrients;

  /// No description provided for @nutritionEnterAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Enter at least calories or one macro nutrient'**
  String get nutritionEnterAtLeastOne;

  /// No description provided for @nutritionHowToFix.
  ///
  /// In en, this message translates to:
  /// **'How to fix'**
  String get nutritionHowToFix;

  /// No description provided for @nutritionHowToImproveAccuracy.
  ///
  /// In en, this message translates to:
  /// **'How to Improve Accuracy'**
  String get nutritionHowToImproveAccuracy;

  /// No description provided for @nutritionEditIngredient.
  ///
  /// In en, this message translates to:
  /// **'Edit Ingredient'**
  String get nutritionEditIngredient;

  /// No description provided for @nutritionSearchUsda.
  ///
  /// In en, this message translates to:
  /// **'Search USDA'**
  String get nutritionSearchUsda;

  /// No description provided for @nutritionEnterManually.
  ///
  /// In en, this message translates to:
  /// **'Enter Manually'**
  String get nutritionEnterManually;

  /// No description provided for @nutritionManualIngredientHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the nutrition values for this ingredient amount. Check the package label or a nutrition database.'**
  String get nutritionManualIngredientHint;

  /// No description provided for @nutritionApplyManual.
  ///
  /// In en, this message translates to:
  /// **'Apply Manual Values'**
  String get nutritionApplyManual;

  /// No description provided for @nutritionTotalRecipe.
  ///
  /// In en, this message translates to:
  /// **'Total Recipe Nutrition'**
  String get nutritionTotalRecipe;

  /// No description provided for @nutritionMatchRate.
  ///
  /// In en, this message translates to:
  /// **'Match Rate'**
  String get nutritionMatchRate;

  /// No description provided for @allergySettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Allergy Settings'**
  String get allergySettingsTitle;

  /// No description provided for @allergyInfoText.
  ///
  /// In en, this message translates to:
  /// **'Select your allergens below. Recipe Spellbook will warn you when recipes contain ingredients you\'re allergic to.'**
  String get allergyInfoText;

  /// No description provided for @allergySelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} allergens selected'**
  String allergySelectedCount(int count);

  /// No description provided for @allergySelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get allergySelectAll;

  /// No description provided for @allergyClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get allergyClearAll;

  /// No description provided for @allergyMajorTitle.
  ///
  /// In en, this message translates to:
  /// **'Major Allergens'**
  String get allergyMajorTitle;

  /// No description provided for @allergyMajorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'FDA-recognized major food allergens'**
  String get allergyMajorSubtitle;

  /// No description provided for @allergyAdditionalTitle.
  ///
  /// In en, this message translates to:
  /// **'Additional Allergens'**
  String get allergyAdditionalTitle;

  /// No description provided for @allergyAdditionalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Other common food sensitivities'**
  String get allergyAdditionalSubtitle;

  /// No description provided for @allergyWillWarn.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be warned about this allergen'**
  String get allergyWillWarn;

  /// No description provided for @allergyWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Allergy Warning'**
  String get allergyWarningTitle;

  /// No description provided for @allergyWarningTitlePossible.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Possible Allergens'**
  String get allergyWarningTitlePossible;

  /// No description provided for @allergyContains.
  ///
  /// In en, this message translates to:
  /// **'Contains:'**
  String get allergyContains;

  /// No description provided for @allergyMayContain.
  ///
  /// In en, this message translates to:
  /// **'May contain:'**
  String get allergyMayContain;

  /// No description provided for @allergyContainsAllergens.
  ///
  /// In en, this message translates to:
  /// **'Contains allergens'**
  String get allergyContainsAllergens;

  /// No description provided for @allergyManageSettings.
  ///
  /// In en, this message translates to:
  /// **'Manage allergy settings'**
  String get allergyManageSettings;

  /// No description provided for @allergyDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Allergen Details'**
  String get allergyDetailsTitle;

  /// No description provided for @settingsAllergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get settingsAllergies;

  /// No description provided for @settingsAllergiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up allergen warnings'**
  String get settingsAllergiesSubtitle;

  /// No description provided for @allergenMilk.
  ///
  /// In en, this message translates to:
  /// **'Milk/Dairy'**
  String get allergenMilk;

  /// No description provided for @allergenEggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get allergenEggs;

  /// No description provided for @allergenFish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get allergenFish;

  /// No description provided for @allergenShellfish.
  ///
  /// In en, this message translates to:
  /// **'Shellfish'**
  String get allergenShellfish;

  /// No description provided for @allergenTreeNuts.
  ///
  /// In en, this message translates to:
  /// **'Tree Nuts'**
  String get allergenTreeNuts;

  /// No description provided for @allergenPeanuts.
  ///
  /// In en, this message translates to:
  /// **'Peanuts'**
  String get allergenPeanuts;

  /// No description provided for @allergenWheat.
  ///
  /// In en, this message translates to:
  /// **'Wheat/Gluten'**
  String get allergenWheat;

  /// No description provided for @allergenSoy.
  ///
  /// In en, this message translates to:
  /// **'Soy'**
  String get allergenSoy;

  /// No description provided for @allergenSesame.
  ///
  /// In en, this message translates to:
  /// **'Sesame'**
  String get allergenSesame;

  /// No description provided for @allergenMustard.
  ///
  /// In en, this message translates to:
  /// **'Mustard'**
  String get allergenMustard;

  /// No description provided for @allergenCelery.
  ///
  /// In en, this message translates to:
  /// **'Celery'**
  String get allergenCelery;

  /// No description provided for @allergenLupin.
  ///
  /// In en, this message translates to:
  /// **'Lupin'**
  String get allergenLupin;

  /// No description provided for @allergenMollusks.
  ///
  /// In en, this message translates to:
  /// **'Mollusks'**
  String get allergenMollusks;

  /// No description provided for @allergenSulfites.
  ///
  /// In en, this message translates to:
  /// **'Sulfites'**
  String get allergenSulfites;

  /// No description provided for @allergenCorn.
  ///
  /// In en, this message translates to:
  /// **'Corn'**
  String get allergenCorn;

  /// No description provided for @allergenNightshades.
  ///
  /// In en, this message translates to:
  /// **'Nightshades'**
  String get allergenNightshades;

  /// No description provided for @nutritionCopyFromAuto.
  ///
  /// In en, this message translates to:
  /// **'Copy from Auto-Calculate'**
  String get nutritionCopyFromAuto;

  /// No description provided for @nutritionEstimatedDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Values are estimated based on USDA data'**
  String get nutritionEstimatedDisclaimer;

  /// No description provided for @actionDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get actionDiscard;

  /// No description provided for @unsavedChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChangesTitle;

  /// No description provided for @unsavedChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you want to save them?'**
  String get unsavedChangesMessage;

  /// No description provided for @tagsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Tags Yet'**
  String get tagsEmptyTitle;

  /// No description provided for @tagsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create tags to organize your recipes by dietary needs, meal type, and more.'**
  String get tagsEmptySubtitle;

  /// No description provided for @tagsLoadDefaults.
  ///
  /// In en, this message translates to:
  /// **'Load Default Tags'**
  String get tagsLoadDefaults;

  /// No description provided for @tagsAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add Tag'**
  String get tagsAddNew;

  /// No description provided for @tagsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Tag'**
  String get tagsEdit;

  /// No description provided for @tagsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Tag'**
  String get tagsDelete;

  /// No description provided for @tagsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String tagsDeleteConfirm(String name);

  /// No description provided for @tagsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Tag Name'**
  String get tagsNameLabel;

  /// No description provided for @tagsIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon (emoji)'**
  String get tagsIconLabel;

  /// No description provided for @tagsColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get tagsColorLabel;

  /// No description provided for @settingsKitchenBuddyEnabled.
  ///
  /// In en, this message translates to:
  /// **'Earn coins and dress up your buddy!'**
  String get settingsKitchenBuddyEnabled;

  /// No description provided for @settingsRecipeLayoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize how recipes are displayed'**
  String get settingsRecipeLayoutSubtitle;

  /// No description provided for @shareLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get shareLink;

  /// No description provided for @shareDocument.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get shareDocument;

  /// No description provided for @sharePrint.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get sharePrint;

  /// No description provided for @shareLinkDescription.
  ///
  /// In en, this message translates to:
  /// **'Share a link that others can use to view this recipe.'**
  String get shareLinkDescription;

  /// No description provided for @shareLinkNote.
  ///
  /// In en, this message translates to:
  /// **'Recipients need the Recipe Spellbook app or can view on web.'**
  String get shareLinkNote;

  /// No description provided for @shareCreatingDocument.
  ///
  /// In en, this message translates to:
  /// **'Creating document...'**
  String get shareCreatingDocument;

  /// No description provided for @editLayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Layout'**
  String get editLayoutTitle;

  /// No description provided for @editLayoutStacked.
  ///
  /// In en, this message translates to:
  /// **'Stacked'**
  String get editLayoutStacked;

  /// No description provided for @editLayoutTabbed.
  ///
  /// In en, this message translates to:
  /// **'Tabbed'**
  String get editLayoutTabbed;

  /// No description provided for @editLayoutStackedDesc.
  ///
  /// In en, this message translates to:
  /// **'All sections in one scrollable view'**
  String get editLayoutStackedDesc;

  /// No description provided for @editLayoutTabbedDesc.
  ///
  /// In en, this message translates to:
  /// **'Separate tabs for details, ingredients, instructions'**
  String get editLayoutTabbedDesc;

  /// No description provided for @tabDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get tabDetails;

  /// No description provided for @tabIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get tabIngredients;

  /// No description provided for @tabInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get tabInstructions;

  /// No description provided for @stepImageAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get stepImageAdd;

  /// No description provided for @stepImageChange.
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get stepImageChange;

  /// No description provided for @stepImageRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove Image'**
  String get stepImageRemove;

  /// No description provided for @stepTimer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get stepTimer;

  /// No description provided for @stepTimerMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String stepTimerMinutes(int minutes);

  /// No description provided for @recipeAddToCookbook.
  ///
  /// In en, this message translates to:
  /// **'Add to Cookbook'**
  String get recipeAddToCookbook;

  /// No description provided for @recipeMoveToTrash.
  ///
  /// In en, this message translates to:
  /// **'Move to Trash'**
  String get recipeMoveToTrash;

  /// No description provided for @tagsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tags'**
  String get tagsEmpty;

  /// No description provided for @nutritionPerServingLabel.
  ///
  /// In en, this message translates to:
  /// **'Per Serving'**
  String get nutritionPerServingLabel;

  /// No description provided for @nutritionTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Recipe'**
  String get nutritionTotalLabel;

  /// No description provided for @trendingRecipes.
  ///
  /// In en, this message translates to:
  /// **'Trending recipes'**
  String get trendingRecipes;

  /// No description provided for @addShortcut.
  ///
  /// In en, this message translates to:
  /// **'Add the Recipe Spellbook shortcut'**
  String get addShortcut;

  /// No description provided for @addShortcutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import recipes with one tap'**
  String get addShortcutSubtitle;

  /// No description provided for @importGuides.
  ///
  /// In en, this message translates to:
  /// **'Read our import guides'**
  String get importGuides;

  /// No description provided for @useOnDesktop.
  ///
  /// In en, this message translates to:
  /// **'Use Recipe Spellbook on desktop'**
  String get useOnDesktop;

  /// No description provided for @inviteFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite friends'**
  String get inviteFriends;

  /// No description provided for @inviteFriendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Recipe Spellbook'**
  String get inviteFriendsTitle;

  /// No description provided for @inviteFriendsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invite your friends and family to start cooking together!'**
  String get inviteFriendsSubtitle;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get maybeLater;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @premiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock sync, unlimited recipes & more'**
  String get premiumSubtitle;

  /// No description provided for @leaderboards.
  ///
  /// In en, this message translates to:
  /// **'Leaderboards'**
  String get leaderboards;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @cookingStats.
  ///
  /// In en, this message translates to:
  /// **'Cooking Stats'**
  String get cookingStats;

  /// No description provided for @stepByStepGuides.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step guides'**
  String get stepByStepGuides;

  /// No description provided for @importGuidesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn how to import recipes from your favorite apps and websites'**
  String get importGuidesSubtitle;

  /// No description provided for @importFromOtherApps.
  ///
  /// In en, this message translates to:
  /// **'Import from other apps'**
  String get importFromOtherApps;

  /// No description provided for @orderOnline.
  ///
  /// In en, this message translates to:
  /// **'Order online'**
  String get orderOnline;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpTitle;

  /// No description provided for @navMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get navMenu;

  /// No description provided for @mealPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'My Meal Plan'**
  String get mealPlanTitle;

  /// No description provided for @noRecipesYet.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet'**
  String get noRecipesYet;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @allergenGluten.
  ///
  /// In en, this message translates to:
  /// **'Gluten'**
  String get allergenGluten;

  /// No description provided for @allergenChocolate.
  ///
  /// In en, this message translates to:
  /// **'Chocolate & Cocoa'**
  String get allergenChocolate;

  /// No description provided for @allergenCaffeine.
  ///
  /// In en, this message translates to:
  /// **'Caffeine'**
  String get allergenCaffeine;

  /// No description provided for @allergenAlcohol.
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get allergenAlcohol;

  /// No description provided for @allergenCitrus.
  ///
  /// In en, this message translates to:
  /// **'Citrus'**
  String get allergenCitrus;

  /// No description provided for @allergenStoneFruits.
  ///
  /// In en, this message translates to:
  /// **'Stone Fruits'**
  String get allergenStoneFruits;

  /// No description provided for @allergenCoconut.
  ///
  /// In en, this message translates to:
  /// **'Coconut'**
  String get allergenCoconut;

  /// No description provided for @allergenGarlic.
  ///
  /// In en, this message translates to:
  /// **'Garlic'**
  String get allergenGarlic;

  /// No description provided for @allergenOnion.
  ///
  /// In en, this message translates to:
  /// **'Onion'**
  String get allergenOnion;

  /// No description provided for @allergenMushrooms.
  ///
  /// In en, this message translates to:
  /// **'Mushrooms'**
  String get allergenMushrooms;

  /// No description provided for @allergenAvocado.
  ///
  /// In en, this message translates to:
  /// **'Avocado'**
  String get allergenAvocado;

  /// No description provided for @allergenBanana.
  ///
  /// In en, this message translates to:
  /// **'Banana'**
  String get allergenBanana;

  /// No description provided for @allergenKiwi.
  ///
  /// In en, this message translates to:
  /// **'Kiwi'**
  String get allergenKiwi;

  /// No description provided for @allergenLatexFoods.
  ///
  /// In en, this message translates to:
  /// **'Latex Cross-Reactive'**
  String get allergenLatexFoods;

  /// No description provided for @allergenFodmap.
  ///
  /// In en, this message translates to:
  /// **'High FODMAP'**
  String get allergenFodmap;

  /// No description provided for @allergenHistamine.
  ///
  /// In en, this message translates to:
  /// **'High Histamine'**
  String get allergenHistamine;

  /// No description provided for @allergenSalicylates.
  ///
  /// In en, this message translates to:
  /// **'Salicylates'**
  String get allergenSalicylates;

  /// No description provided for @allergenMsg.
  ///
  /// In en, this message translates to:
  /// **'MSG'**
  String get allergenMsg;

  /// No description provided for @allergenRedMeat.
  ///
  /// In en, this message translates to:
  /// **'Red Meat (Alpha-gal)'**
  String get allergenRedMeat;

  /// No description provided for @allergenGelatin.
  ///
  /// In en, this message translates to:
  /// **'Gelatin'**
  String get allergenGelatin;

  /// No description provided for @allergyWarningContains.
  ///
  /// In en, this message translates to:
  /// **'May contain:'**
  String get allergyWarningContains;

  /// No description provided for @allergyDismissForRecipe.
  ///
  /// In en, this message translates to:
  /// **'Dismiss for this recipe'**
  String get allergyDismissForRecipe;

  /// No description provided for @allergyDismissUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get allergyDismissUndo;

  /// No description provided for @allergyWarningDismissed.
  ///
  /// In en, this message translates to:
  /// **'Warning dismissed for this recipe'**
  String get allergyWarningDismissed;

  /// No description provided for @scaleCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get scaleCustom;

  /// No description provided for @scaleCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Scale'**
  String get scaleCustomTitle;

  /// No description provided for @scaleCustomHint.
  ///
  /// In en, this message translates to:
  /// **'Enter any number (e.g., 0.75 for 3/4, 2.5 for 2½)'**
  String get scaleCustomHint;

  /// No description provided for @scaleApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get scaleApply;

  /// No description provided for @addStep.
  ///
  /// In en, this message translates to:
  /// **'Add step'**
  String get addStep;

  /// No description provided for @noInstructionsYet.
  ///
  /// In en, this message translates to:
  /// **'No instructions yet'**
  String get noInstructionsYet;

  /// No description provided for @addFirstStep.
  ///
  /// In en, this message translates to:
  /// **'Add first step'**
  String get addFirstStep;

  /// No description provided for @enterInstruction.
  ///
  /// In en, this message translates to:
  /// **'Enter instruction...'**
  String get enterInstruction;

  /// No description provided for @addStepImage.
  ///
  /// In en, this message translates to:
  /// **'Add step image'**
  String get addStepImage;

  /// No description provided for @removeStep.
  ///
  /// In en, this message translates to:
  /// **'Remove step'**
  String get removeStep;

  /// No description provided for @plannerNoMeals.
  ///
  /// In en, this message translates to:
  /// **'No meals planned'**
  String get plannerNoMeals;

  /// No description provided for @plannerAddMealHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a meal for this day'**
  String get plannerAddMealHint;

  /// No description provided for @plannerMealAdded.
  ///
  /// In en, this message translates to:
  /// **'{recipe} added to {mealType}'**
  String plannerMealAdded(String recipe, String mealType);

  /// No description provided for @plannerShareMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Share meal plan'**
  String get plannerShareMealPlan;

  /// No description provided for @plannerAddWeekToShopping.
  ///
  /// In en, this message translates to:
  /// **'Add week to shopping list'**
  String get plannerAddWeekToShopping;

  /// No description provided for @plannerClearWeek.
  ///
  /// In en, this message translates to:
  /// **'Clear this week'**
  String get plannerClearWeek;

  /// No description provided for @plannerClearWeekConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will remove all meals planned for this week. This cannot be undone.'**
  String get plannerClearWeekConfirm;

  /// No description provided for @plannerWeekCleared.
  ///
  /// In en, this message translates to:
  /// **'Week cleared'**
  String get plannerWeekCleared;

  /// No description provided for @plannerGoToToday.
  ///
  /// In en, this message translates to:
  /// **'Go to today'**
  String get plannerGoToToday;

  /// No description provided for @plannerAddAnother.
  ///
  /// In en, this message translates to:
  /// **'Add another meal'**
  String get plannerAddAnother;

  /// No description provided for @plannerSearchRecipes.
  ///
  /// In en, this message translates to:
  /// **'Search recipes...'**
  String get plannerSearchRecipes;

  /// No description provided for @mealTypeBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealTypeBreakfast;

  /// No description provided for @mealTypeLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealTypeLunch;

  /// No description provided for @mealTypeDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealTypeDinner;

  /// No description provided for @mealTypeSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get mealTypeSnack;

  /// No description provided for @shoppingItems.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{item} other{items}}'**
  String shoppingItems(int count);

  /// No description provided for @shoppingBySection.
  ///
  /// In en, this message translates to:
  /// **'By Section'**
  String get shoppingBySection;

  /// No description provided for @shoppingByRecipe.
  ///
  /// In en, this message translates to:
  /// **'By Recipe'**
  String get shoppingByRecipe;

  /// No description provided for @shoppingUngrouped.
  ///
  /// In en, this message translates to:
  /// **'Ungrouped'**
  String get shoppingUngrouped;

  /// No description provided for @shoppingOrderOnline.
  ///
  /// In en, this message translates to:
  /// **'Order online'**
  String get shoppingOrderOnline;

  /// No description provided for @shoppingEditItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get shoppingEditItem;

  /// No description provided for @shoppingItemName.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get shoppingItemName;

  /// No description provided for @shoppingSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get shoppingSelectCategory;

  /// No description provided for @shoppingAddedManually.
  ///
  /// In en, this message translates to:
  /// **'Added manually'**
  String get shoppingAddedManually;

  /// No description provided for @shoppingEmptyList.
  ///
  /// In en, this message translates to:
  /// **'Your list is empty'**
  String get shoppingEmptyList;

  /// No description provided for @shoppingEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add items or add ingredients from your recipes'**
  String get shoppingEmptyHint;

  /// No description provided for @shoppingAddHint.
  ///
  /// In en, this message translates to:
  /// **'Press Enter or tap send to add, then type the next item'**
  String get shoppingAddHint;

  /// No description provided for @categoryDeli.
  ///
  /// In en, this message translates to:
  /// **'Deli'**
  String get categoryDeli;

  /// No description provided for @categoryBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast & Cereal'**
  String get categoryBreakfast;

  /// No description provided for @categoryCanned.
  ///
  /// In en, this message translates to:
  /// **'Canned Goods & Soups'**
  String get categoryCanned;

  /// No description provided for @categoryCondiments.
  ///
  /// In en, this message translates to:
  /// **'Condiments, Sauces & Spices'**
  String get categoryCondiments;

  /// No description provided for @categoryAlcohol.
  ///
  /// In en, this message translates to:
  /// **'Beer, Wine & Spirits'**
  String get categoryAlcohol;

  /// No description provided for @categoryBaby.
  ///
  /// In en, this message translates to:
  /// **'Baby'**
  String get categoryBaby;

  /// No description provided for @categoryBeauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty & Personal Care'**
  String get categoryBeauty;

  /// No description provided for @categoryHousehold.
  ///
  /// In en, this message translates to:
  /// **'Housewares'**
  String get categoryHousehold;

  /// No description provided for @categoryPet.
  ///
  /// In en, this message translates to:
  /// **'Pet'**
  String get categoryPet;

  /// No description provided for @importFromPlatform.
  ///
  /// In en, this message translates to:
  /// **'Import from {platform}'**
  String importFromPlatform(String platform);

  /// No description provided for @importFromApp.
  ///
  /// In en, this message translates to:
  /// **'Import from {app}'**
  String importFromApp(String app);

  /// No description provided for @helpAddingRecipes.
  ///
  /// In en, this message translates to:
  /// **'Adding Recipes'**
  String get helpAddingRecipes;

  /// No description provided for @helpAddingRecipesDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button in any cookbook to add a recipe. You can import from URLs, take photos, or enter manually.'**
  String get helpAddingRecipesDesc;

  /// No description provided for @helpImporting.
  ///
  /// In en, this message translates to:
  /// **'Importing from Apps'**
  String get helpImporting;

  /// No description provided for @helpImportingDesc.
  ///
  /// In en, this message translates to:
  /// **'Share a recipe from Instagram, TikTok, or any website directly to Recipe Spellbook.'**
  String get helpImportingDesc;

  /// No description provided for @helpMealPlanning.
  ///
  /// In en, this message translates to:
  /// **'Meal Planning'**
  String get helpMealPlanning;

  /// No description provided for @helpMealPlanningDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap the Meal Plan tab to plan your meals for the week. Tap + on any day to add recipes.'**
  String get helpMealPlanningDesc;

  /// No description provided for @helpShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping Lists'**
  String get helpShopping;

  /// No description provided for @helpShoppingDesc.
  ///
  /// In en, this message translates to:
  /// **'Add ingredients from recipes to your shopping list. Items are organized by store section.'**
  String get helpShoppingDesc;

  /// No description provided for @helpSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get helpSyncing;

  /// No description provided for @helpSyncingDesc.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync is coming soon! Your recipes will sync across all your devices.'**
  String get helpSyncingDesc;

  /// No description provided for @helpContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get helpContactUs;

  /// No description provided for @helpContactUsDesc.
  ///
  /// In en, this message translates to:
  /// **'Have questions or feedback? Email us at support@recipespellbook.com'**
  String get helpContactUsDesc;

  /// No description provided for @navCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get navCommunity;

  /// No description provided for @navComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get navComingSoon;

  /// No description provided for @mealPlanButton.
  ///
  /// In en, this message translates to:
  /// **'Meal Plan'**
  String get mealPlanButton;

  /// No description provided for @groceriesButton.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get groceriesButton;

  /// No description provided for @shareButton.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareButton;

  /// No description provided for @scaleRecipeButton.
  ///
  /// In en, this message translates to:
  /// **'Scale'**
  String get scaleRecipeButton;

  /// No description provided for @convertUnitsButton.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get convertUnitsButton;

  /// No description provided for @allergyDismissTooltip.
  ///
  /// In en, this message translates to:
  /// **'Dismiss warning'**
  String get allergyDismissTooltip;

  /// No description provided for @allergyDisablePrompt.
  ///
  /// In en, this message translates to:
  /// **'Disable this warning permanently for this recipe?'**
  String get allergyDisablePrompt;

  /// No description provided for @allergyDisabledForRecipe.
  ///
  /// In en, this message translates to:
  /// **'Warning disabled for this recipe'**
  String get allergyDisabledForRecipe;

  /// No description provided for @allergyRestoreWarnings.
  ///
  /// In en, this message translates to:
  /// **'Restore warnings'**
  String get allergyRestoreWarnings;

  /// No description provided for @recipeDuplicated.
  ///
  /// In en, this message translates to:
  /// **'Recipe duplicated'**
  String get recipeDuplicated;

  /// No description provided for @recipeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Recipe moved to trash'**
  String get recipeDeleted;

  /// No description provided for @deleteRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Recipe'**
  String get deleteRecipeTitle;

  /// No description provided for @deleteRecipeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this recipe? It will be moved to trash.'**
  String get deleteRecipeConfirm;

  /// No description provided for @addToShoppingListTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to Shopping List'**
  String get addToShoppingListTitle;

  /// No description provided for @viewList.
  ///
  /// In en, this message translates to:
  /// **'View List'**
  String get viewList;

  /// No description provided for @selectItems.
  ///
  /// In en, this message translates to:
  /// **'Select items'**
  String get selectItems;

  /// No description provided for @addToListCount.
  ///
  /// In en, this message translates to:
  /// **'Add {count} items'**
  String addToListCount(int count);

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @unselectAll.
  ///
  /// In en, this message translates to:
  /// **'Unselect All'**
  String get unselectAll;

  /// No description provided for @deleteStep.
  ///
  /// In en, this message translates to:
  /// **'Delete Step'**
  String get deleteStep;

  /// No description provided for @deleteSteps.
  ///
  /// In en, this message translates to:
  /// **'Delete Steps'**
  String get deleteSteps;

  /// No description provided for @deleteStepConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this step?'**
  String get deleteStepConfirm;

  /// No description provided for @deleteStepsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} steps?'**
  String deleteStepsConfirm(int count);

  /// No description provided for @stepSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String stepSelected(int count);

  /// No description provided for @selectAllSteps.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAllSteps;

  /// No description provided for @gradientBased.
  ///
  /// In en, this message translates to:
  /// **'Gradient-Based'**
  String get gradientBased;

  /// No description provided for @gradientBasedDescription.
  ///
  /// In en, this message translates to:
  /// **'Color gradient based on your theme'**
  String get gradientBasedDescription;

  /// No description provided for @startCooking.
  ///
  /// In en, this message translates to:
  /// **'Start Cooking'**
  String get startCooking;

  /// No description provided for @fontSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSizeLabel;

  /// No description provided for @krogerLoginDenied.
  ///
  /// In en, this message translates to:
  /// **'Kroger login was denied: {error}'**
  String krogerLoginDenied(String error);

  /// No description provided for @krogerNoAuthCode.
  ///
  /// In en, this message translates to:
  /// **'No authorization code received from Kroger.'**
  String get krogerNoAuthCode;

  /// No description provided for @krogerConnected.
  ///
  /// In en, this message translates to:
  /// **'Kroger connected! You can now send items directly to your cart.'**
  String get krogerConnected;

  /// No description provided for @krogerConnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect Kroger. Please try again.'**
  String get krogerConnectFailed;

  /// No description provided for @krogerConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to Kroger…'**
  String get krogerConnecting;

  /// No description provided for @krogerExchanging.
  ///
  /// In en, this message translates to:
  /// **'Exchanging authorization...'**
  String get krogerExchanging;

  /// No description provided for @krogerConnectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Connected!'**
  String get krogerConnectedTitle;

  /// No description provided for @krogerConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection Failed'**
  String get krogerConnectionFailed;

  /// No description provided for @goToShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Go to Shopping List'**
  String get goToShoppingList;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @skipDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Skip dupes'**
  String get skipDuplicates;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get deselectAll;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @recipesImported.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{recipe} other{recipes}} imported'**
  String recipesImported(int count);

  /// No description provided for @importCountRecipes.
  ///
  /// In en, this message translates to:
  /// **'Import {count} {count, plural, =1{recipe} other{recipes}}'**
  String importCountRecipes(int count);

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product Not Found'**
  String get productNotFound;

  /// No description provided for @barcodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'No product found for barcode:\n{barcode}'**
  String barcodeNotFound(String barcode);

  /// No description provided for @manualEntryHint.
  ///
  /// In en, this message translates to:
  /// **'You can manually enter the product name.'**
  String get manualEntryHint;

  /// No description provided for @scanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get scanAgain;

  /// No description provided for @enterManually.
  ///
  /// In en, this message translates to:
  /// **'Enter Manually'**
  String get enterManually;

  /// No description provided for @enterProductName.
  ///
  /// In en, this message translates to:
  /// **'Enter Product Name'**
  String get enterProductName;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get productName;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scanBarcode;

  /// No description provided for @lookingUpProduct.
  ///
  /// In en, this message translates to:
  /// **'Looking up product...'**
  String get lookingUpProduct;

  /// No description provided for @pointCameraBarcode.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at a product barcode'**
  String get pointCameraBarcode;

  /// No description provided for @unknownProduct.
  ///
  /// In en, this message translates to:
  /// **'Unknown Product'**
  String get unknownProduct;

  /// No description provided for @nutritionPer100g.
  ///
  /// In en, this message translates to:
  /// **'Nutrition (per 100g)'**
  String get nutritionPer100g;

  /// No description provided for @findRecipesWithThis.
  ///
  /// In en, this message translates to:
  /// **'Find Recipes with This'**
  String get findRecipesWithThis;

  /// No description provided for @scanAnother.
  ///
  /// In en, this message translates to:
  /// **'Scan Another'**
  String get scanAnother;

  /// No description provided for @exportFormat.
  ///
  /// In en, this message translates to:
  /// **'Export Format'**
  String get exportFormat;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @shareMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Share meal plan'**
  String get shareMealPlan;

  /// No description provided for @addWeekToShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Add week to shopping list'**
  String get addWeekToShoppingList;

  /// No description provided for @clearThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Clear this week?'**
  String get clearThisWeek;

  /// No description provided for @clearWeekWarning.
  ///
  /// In en, this message translates to:
  /// **'This will remove all meals planned for this week. This cannot be undone.'**
  String get clearWeekWarning;

  /// No description provided for @goToToday.
  ///
  /// In en, this message translates to:
  /// **'Go to today'**
  String get goToToday;

  /// No description provided for @addAnotherMeal.
  ///
  /// In en, this message translates to:
  /// **'Add another meal'**
  String get addAnotherMeal;

  /// No description provided for @meal.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get meal;

  /// No description provided for @noMealsPlanned.
  ///
  /// In en, this message translates to:
  /// **'No meals planned'**
  String get noMealsPlanned;

  /// No description provided for @tapToAddMeal.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a meal for this day'**
  String get tapToAddMeal;

  /// No description provided for @addMeal.
  ///
  /// In en, this message translates to:
  /// **'Add meal'**
  String get addMeal;

  /// No description provided for @addToDay.
  ///
  /// In en, this message translates to:
  /// **'Add to {dayName}'**
  String addToDay(String dayName);

  /// No description provided for @searchRecipes.
  ///
  /// In en, this message translates to:
  /// **'Search recipes...'**
  String get searchRecipes;

  /// No description provided for @noRecipesFound.
  ///
  /// In en, this message translates to:
  /// **'No recipes found'**
  String get noRecipesFound;

  /// No description provided for @exitShoppingListGenerator.
  ///
  /// In en, this message translates to:
  /// **'Exit Shopping List Generator?'**
  String get exitShoppingListGenerator;

  /// No description provided for @actionExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get actionExit;

  /// No description provided for @shoppingListGenerator.
  ///
  /// In en, this message translates to:
  /// **'Shopping List Generator'**
  String get shoppingListGenerator;

  /// No description provided for @reviewAndAdd.
  ///
  /// In en, this message translates to:
  /// **'Review & Add ({count} items)'**
  String reviewAndAdd(int count);

  /// No description provided for @addItemsToList.
  ///
  /// In en, this message translates to:
  /// **'Add {count} items to list'**
  String addItemsToList(int count);

  /// No description provided for @addedItemsToShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Added {count} items to shopping list'**
  String addedItemsToShoppingList(int count);

  /// No description provided for @createNewList.
  ///
  /// In en, this message translates to:
  /// **'Create new list'**
  String get createNewList;

  /// No description provided for @listName.
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get listName;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @myPantry.
  ///
  /// In en, this message translates to:
  /// **'My Pantry'**
  String get myPantry;

  /// No description provided for @itemsAlwaysOnHand.
  ///
  /// In en, this message translates to:
  /// **'Items you always have on hand'**
  String get itemsAlwaysOnHand;

  /// No description provided for @whatToDelete.
  ///
  /// In en, this message translates to:
  /// **'What would you like to delete?'**
  String get whatToDelete;

  /// No description provided for @localData.
  ///
  /// In en, this message translates to:
  /// **'Local Data'**
  String get localData;

  /// No description provided for @localDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Deletes recipes, cookbooks, meal plans, and shopping lists on this device only. Cloud data stays intact and will sync back.'**
  String get localDataDesc;

  /// No description provided for @allData.
  ///
  /// In en, this message translates to:
  /// **'All Data'**
  String get allData;

  /// No description provided for @allDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanently deletes EVERYTHING — local data, cloud data, and your account. Complete fresh start.'**
  String get allDataDesc;

  /// No description provided for @allDataWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'This will delete everything'**
  String get allDataWarningTitle;

  /// No description provided for @allDataWarningCloudData.
  ///
  /// In en, this message translates to:
  /// **'All recipes, cookbooks, and meal plans synced to the cloud'**
  String get allDataWarningCloudData;

  /// No description provided for @allDataWarningLocalData.
  ///
  /// In en, this message translates to:
  /// **'All local data on this device'**
  String get allDataWarningLocalData;

  /// No description provided for @allDataWarningAccount.
  ///
  /// In en, this message translates to:
  /// **'Your account (subscription restores automatically on sign-in)'**
  String get allDataWarningAccount;

  /// No description provided for @allDataWarningSettings.
  ///
  /// In en, this message translates to:
  /// **'All app settings and preferences'**
  String get allDataWarningSettings;

  /// No description provided for @allDataIUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I understand this will permanently delete all my data'**
  String get allDataIUnderstand;

  /// No description provided for @allDataNoUndo.
  ///
  /// In en, this message translates to:
  /// **'I understand this action cannot be undone'**
  String get allDataNoUndo;

  /// No description provided for @localNoCloudWarning.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have Cloud Sync — there is no backup to recover from'**
  String get localNoCloudWarning;

  /// No description provided for @permanentDeleteWarning.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete {scope}. This cannot be undone.'**
  String permanentDeleteWarning(String scope);

  /// No description provided for @dataResetComplete.
  ///
  /// In en, this message translates to:
  /// **'Data Reset Complete'**
  String get dataResetComplete;

  /// No description provided for @noThanks.
  ///
  /// In en, this message translates to:
  /// **'No thanks'**
  String get noThanks;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(String error);

  /// No description provided for @yesAddThem.
  ///
  /// In en, this message translates to:
  /// **'Yes, add them'**
  String get yesAddThem;

  /// No description provided for @nutritionDisplay.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Display'**
  String get nutritionDisplay;

  /// No description provided for @nutritionDisplaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Chart style, visible nutrients'**
  String get nutritionDisplaySubtitle;

  /// No description provided for @storeIntegrations.
  ///
  /// In en, this message translates to:
  /// **'Store Integrations'**
  String get storeIntegrations;

  /// No description provided for @instacart.
  ///
  /// In en, this message translates to:
  /// **'Instacart'**
  String get instacart;

  /// No description provided for @kroger.
  ///
  /// In en, this message translates to:
  /// **'Kroger'**
  String get kroger;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @setCustomApiKey.
  ///
  /// In en, this message translates to:
  /// **'Set custom API key'**
  String get setCustomApiKey;

  /// No description provided for @useOwnInstacartKey.
  ///
  /// In en, this message translates to:
  /// **'Use your own Instacart Connect key'**
  String get useOwnInstacartKey;

  /// No description provided for @instacartApiKey.
  ///
  /// In en, this message translates to:
  /// **'Instacart API Key'**
  String get instacartApiKey;

  /// No description provided for @resetToDefaultKey.
  ///
  /// In en, this message translates to:
  /// **'Reset to default key'**
  String get resetToDefaultKey;

  /// No description provided for @removeCustomKey.
  ///
  /// In en, this message translates to:
  /// **'Remove custom key, use built-in'**
  String get removeCustomKey;

  /// No description provided for @signInToKroger.
  ///
  /// In en, this message translates to:
  /// **'Sign in to Kroger'**
  String get signInToKroger;

  /// No description provided for @connectToAddItems.
  ///
  /// In en, this message translates to:
  /// **'Connect to add items to your cart'**
  String get connectToAddItems;

  /// No description provided for @setPreferredStore.
  ///
  /// In en, this message translates to:
  /// **'Set preferred store'**
  String get setPreferredStore;

  /// No description provided for @searchByZipCode.
  ///
  /// In en, this message translates to:
  /// **'Search by zip code'**
  String get searchByZipCode;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @apiKeySaved.
  ///
  /// In en, this message translates to:
  /// **'API key saved'**
  String get apiKeySaved;

  /// No description provided for @findYourKrogerStore.
  ///
  /// In en, this message translates to:
  /// **'Find your Kroger store'**
  String get findYourKrogerStore;

  /// No description provided for @enterZipCode.
  ///
  /// In en, this message translates to:
  /// **'Enter zip code'**
  String get enterZipCode;

  /// No description provided for @storeSet.
  ///
  /// In en, this message translates to:
  /// **'Store set: {name}'**
  String storeSet(String name);

  /// No description provided for @menuImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Instagram, TikTok, websites...'**
  String get menuImportSubtitle;

  /// No description provided for @menuSyncToMobile.
  ///
  /// In en, this message translates to:
  /// **'Sync to mobile'**
  String get menuSyncToMobile;

  /// No description provided for @menuSyncToDesktop.
  ///
  /// In en, this message translates to:
  /// **'Sync to desktop'**
  String get menuSyncToDesktop;

  /// No description provided for @menuTransferToPhone.
  ///
  /// In en, this message translates to:
  /// **'Transfer data to your phone'**
  String get menuTransferToPhone;

  /// No description provided for @menuTransferToDevice.
  ///
  /// In en, this message translates to:
  /// **'Transfer data to another device'**
  String get menuTransferToDevice;

  /// No description provided for @menuProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get menuProfile;

  /// No description provided for @menuProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your stats and progress'**
  String get menuProfileSubtitle;

  /// No description provided for @menuAchievementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock rewards'**
  String get menuAchievementsSubtitle;

  /// No description provided for @menuCosmetics.
  ///
  /// In en, this message translates to:
  /// **'Cosmetics'**
  String get menuCosmetics;

  /// No description provided for @menuCosmeticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize your look'**
  String get menuCosmeticsSubtitle;

  /// No description provided for @menuLeaderboardsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Compete with others'**
  String get menuLeaderboardsSubtitle;

  /// No description provided for @menuBossBattles.
  ///
  /// In en, this message translates to:
  /// **'Boss Battles'**
  String get menuBossBattles;

  /// No description provided for @menuBossBattlesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Epic cooking challenges'**
  String get menuBossBattlesSubtitle;

  /// No description provided for @menuImportRecipes.
  ///
  /// In en, this message translates to:
  /// **'Import Recipes'**
  String get menuImportRecipes;

  /// No description provided for @menuHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get menuHelpSupport;

  /// No description provided for @menuAppVersion.
  ///
  /// In en, this message translates to:
  /// **'Recipe Spellbook v{version}'**
  String menuAppVersion(String version);

  /// No description provided for @menuShareApp.
  ///
  /// In en, this message translates to:
  /// **'Share Recipe Spellbook'**
  String get menuShareApp;

  /// No description provided for @menuShareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invite your friends and family to start cooking together!'**
  String get menuShareSubtitle;

  /// No description provided for @menuShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Check out Recipe Spellbook - the best recipe app! https://recipespellbook.app/get'**
  String get menuShareMessage;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @helpFromWebsite.
  ///
  /// In en, this message translates to:
  /// **'From a website'**
  String get helpFromWebsite;

  /// No description provided for @helpFromWebsiteDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap + in any cookbook, then paste a recipe URL. Works with most recipe sites including AllRecipes, Food Network, NYT Cooking, and thousands more.'**
  String get helpFromWebsiteDesc;

  /// No description provided for @helpFromSocial.
  ///
  /// In en, this message translates to:
  /// **'From Instagram or TikTok'**
  String get helpFromSocial;

  /// No description provided for @helpFromSocialDesc.
  ///
  /// In en, this message translates to:
  /// **'Copy the link to a recipe post, then tap + and paste it. Recipe Spellbook will extract the recipe from the page.'**
  String get helpFromSocialDesc;

  /// No description provided for @helpFromPhoto.
  ///
  /// In en, this message translates to:
  /// **'From a photo'**
  String get helpFromPhoto;

  /// No description provided for @helpFromPhotoDesc.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of a recipe in a cookbook or magazine. Tap + then choose Image to scan it with OCR.'**
  String get helpFromPhotoDesc;

  /// No description provided for @helpFromPdf.
  ///
  /// In en, this message translates to:
  /// **'From a PDF'**
  String get helpFromPdf;

  /// No description provided for @helpFromPdfDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap + then choose File to import a PDF recipe. The text will be extracted automatically.'**
  String get helpFromPdfDesc;

  /// No description provided for @helpFromText.
  ///
  /// In en, this message translates to:
  /// **'From text'**
  String get helpFromText;

  /// No description provided for @helpFromTextDesc.
  ///
  /// In en, this message translates to:
  /// **'Copy recipe text from anywhere, tap + then Paste. Recipe Spellbook will detect ingredients and instructions.'**
  String get helpFromTextDesc;

  /// No description provided for @helpFromPaprika.
  ///
  /// In en, this message translates to:
  /// **'From Paprika'**
  String get helpFromPaprika;

  /// No description provided for @helpFromPaprikaDesc.
  ///
  /// In en, this message translates to:
  /// **'In Paprika, go to Export and choose \"HTML\" format. Then tap + in Recipe Spellbook and import the HTML file.'**
  String get helpFromPaprikaDesc;

  /// No description provided for @helpFromOtherApps.
  ///
  /// In en, this message translates to:
  /// **'From other apps'**
  String get helpFromOtherApps;

  /// No description provided for @helpFromOtherAppsDesc.
  ///
  /// In en, this message translates to:
  /// **'Most recipe apps can export as HTML or text. Export from your old app, then import the file here using the + button.'**
  String get helpFromOtherAppsDesc;

  /// No description provided for @helpCloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get helpCloudSync;

  /// No description provided for @helpCloudSyncDesc.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Cloud Sync to keep your recipes in sync across all your devices. Tap the sync button in the sidebar to sync manually.'**
  String get helpCloudSyncDesc;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @accountSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get accountSubscription;

  /// No description provided for @accountManageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get accountManageSubscription;

  /// No description provided for @accountCloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get accountCloudSync;

  /// No description provided for @accountSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get accountSyncNow;

  /// No description provided for @accountIntegrations.
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get accountIntegrations;

  /// No description provided for @accountDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get accountDangerZone;

  /// No description provided for @purchasesRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored successfully!'**
  String get purchasesRestored;

  /// No description provided for @noPurchasesFound.
  ///
  /// In en, this message translates to:
  /// **'No previous purchases found.'**
  String get noPurchasesFound;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed. Please try again.'**
  String get restoreFailed;

  /// No description provided for @restorePurchasesLong.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchasesLong;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @accessUntil.
  ///
  /// In en, this message translates to:
  /// **'access until'**
  String get accessUntil;

  /// No description provided for @renews.
  ///
  /// In en, this message translates to:
  /// **'Renews'**
  String get renews;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @upgradeDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlock cloud sync, smart import, and more.'**
  String get upgradeDescription;

  /// No description provided for @syncDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep your recipes synced across devices.'**
  String get syncDescription;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// No description provided for @signInToSync.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync recipes'**
  String get signInToSync;

  /// No description provided for @signInSyncDesc.
  ///
  /// In en, this message translates to:
  /// **'Back up your recipes, sync across devices, and unlock premium features.'**
  String get signInSyncDesc;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutQuestion;

  /// No description provided for @signOutDesc.
  ///
  /// In en, this message translates to:
  /// **'Your recipes stay on this device. You can sign back in anytime to re-enable sync.'**
  String get signOutDesc;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountQuestion;

  /// No description provided for @deleteAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and all synced data from our servers.\n\nRecipes stored locally on this device will NOT be deleted.'**
  String get deleteAccountDesc;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deletePermanently;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account. Please try again.'**
  String get deleteAccountFailed;

  /// No description provided for @signInToApp.
  ///
  /// In en, this message translates to:
  /// **'Sign in to Recipe Spellbook'**
  String get signInToApp;

  /// No description provided for @signInSyncLong.
  ///
  /// In en, this message translates to:
  /// **'Sync your recipes across devices, unlock cloud backup, and access Pro features.'**
  String get signInSyncLong;

  /// No description provided for @recipesStayOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Your recipes stay on this device even without an account.'**
  String get recipesStayOnDevice;

  /// No description provided for @upgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgradeToPro;

  /// No description provided for @subscriptionDot.
  ///
  /// In en, this message translates to:
  /// **'Subscription · {tier}'**
  String subscriptionDot(String tier);

  /// No description provided for @affluentLabsPro.
  ///
  /// In en, this message translates to:
  /// **'Affluent Labs Pro'**
  String get affluentLabsPro;

  /// No description provided for @cancelledAccessUntil.
  ///
  /// In en, this message translates to:
  /// **'Cancelled — access until {date}'**
  String cancelledAccessUntil(String date);

  /// No description provided for @lifetimeNeverExpires.
  ///
  /// In en, this message translates to:
  /// **'Lifetime — never expires'**
  String get lifetimeNeverExpires;

  /// No description provided for @renewsDate.
  ///
  /// In en, this message translates to:
  /// **'Renews {date}'**
  String renewsDate(String date);

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manageSubscription;

  /// No description provided for @tierPremium.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get tierPremium;

  /// No description provided for @tierStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get tierStandard;

  /// No description provided for @tierBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get tierBasic;

  /// No description provided for @tierFree.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get tierFree;

  /// No description provided for @tierPlan.
  ///
  /// In en, this message translates to:
  /// **'{tier} Plan'**
  String tierPlan(String tier);

  /// No description provided for @upgradeArrow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade →'**
  String get upgradeArrow;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @lastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last synced {time}'**
  String lastSynced(String time);

  /// No description provided for @notYetSynced.
  ///
  /// In en, this message translates to:
  /// **'Not yet synced'**
  String get notYetSynced;

  /// No description provided for @cloudSyncSection.
  ///
  /// In en, this message translates to:
  /// **'CLOUD SYNC'**
  String get cloudSyncSection;

  /// No description provided for @noRecipesPlannedThisWeek.
  ///
  /// In en, this message translates to:
  /// **'No recipes planned this week'**
  String get noRecipesPlannedThisWeek;

  /// No description provided for @todayBadge.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get todayBadge;

  /// No description provided for @noCourseAssigned.
  ///
  /// In en, this message translates to:
  /// **'No Course Assigned'**
  String get noCourseAssigned;

  /// No description provided for @uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// No description provided for @allRecipesHaveCourse.
  ///
  /// In en, this message translates to:
  /// **'All recipes have a course!'**
  String get allRecipesHaveCourse;

  /// No description provided for @allRecipesCategorized.
  ///
  /// In en, this message translates to:
  /// **'All recipes are categorized!'**
  String get allRecipesCategorized;

  /// No description provided for @greatJobOrganizing.
  ///
  /// In en, this message translates to:
  /// **'Great job organizing your recipes.'**
  String get greatJobOrganizing;

  /// No description provided for @countOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total}'**
  String countOfTotal(int count, int total);

  /// No description provided for @tapToAssignCourse.
  ///
  /// In en, this message translates to:
  /// **'Tap to assign a course'**
  String get tapToAssignCourse;

  /// No description provided for @tapToAssignCategory.
  ///
  /// In en, this message translates to:
  /// **'Tap to assign a category'**
  String get tapToAssignCategory;

  /// No description provided for @deleteCountRecipes.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} {count, plural, =1{recipe} other{recipes}}?'**
  String deleteCountRecipes(int count);

  /// No description provided for @countRecipesMovedToTrash.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{recipe} other{recipes}} moved to trash'**
  String countRecipesMovedToTrash(int count);

  /// No description provided for @setCourse.
  ///
  /// In en, this message translates to:
  /// **'Set Course'**
  String get setCourse;

  /// No description provided for @setCategory.
  ///
  /// In en, this message translates to:
  /// **'Set Category'**
  String get setCategory;

  /// No description provided for @courseSetForCount.
  ///
  /// In en, this message translates to:
  /// **'Course set for {count} {count, plural, =1{recipe} other{recipes}}'**
  String courseSetForCount(int count);

  /// No description provided for @categorySetForCount.
  ///
  /// In en, this message translates to:
  /// **'Category set for {count} {count, plural, =1{recipe} other{recipes}}'**
  String categorySetForCount(int count);

  /// No description provided for @countRecipesFavorited.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{recipe} other{recipes}} favorited'**
  String countRecipesFavorited(int count);

  /// No description provided for @bulkCourse.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get bulkCourse;

  /// No description provided for @bulkCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get bulkCategory;

  /// No description provided for @bulkFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get bulkFavorite;

  /// No description provided for @aiImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from AI'**
  String get aiImportTitle;

  /// No description provided for @aiCopyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Copy the prompt'**
  String get aiCopyPrompt;

  /// No description provided for @aiCopyPromptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Paste this into ChatGPT, Claude, Gemini, or any AI along with your recipe.'**
  String get aiCopyPromptSubtitle;

  /// No description provided for @aiCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get aiCopied;

  /// No description provided for @aiCopyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy Prompt to Clipboard'**
  String get aiCopyToClipboard;

  /// No description provided for @aiPreviewPrompt.
  ///
  /// In en, this message translates to:
  /// **'Preview prompt'**
  String get aiPreviewPrompt;

  /// No description provided for @aiPasteOutput.
  ///
  /// In en, this message translates to:
  /// **'Paste the AI output'**
  String get aiPasteOutput;

  /// No description provided for @aiPasteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Paste the JSON the AI gave you, or import a .json file.'**
  String get aiPasteSubtitle;

  /// No description provided for @aiPasteFirst.
  ///
  /// In en, this message translates to:
  /// **'Paste or load JSON first.'**
  String get aiPasteFirst;

  /// No description provided for @aiFailedReadFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to read file: {error}'**
  String aiFailedReadFile(String error);

  /// No description provided for @aiUntitledRecipe.
  ///
  /// In en, this message translates to:
  /// **'Untitled Recipe'**
  String get aiUntitledRecipe;

  /// No description provided for @aiImporting.
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get aiImporting;

  /// No description provided for @aiImportToCookbook.
  ///
  /// In en, this message translates to:
  /// **'Import to Cookbook'**
  String get aiImportToCookbook;

  /// No description provided for @aiImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Recipe imported successfully!'**
  String get aiImportSuccess;

  /// No description provided for @aiPreviewImport.
  ///
  /// In en, this message translates to:
  /// **'Preview & Import'**
  String get aiPreviewImport;

  /// No description provided for @aiPromptCopied.
  ///
  /// In en, this message translates to:
  /// **'Prompt copied! Paste it into any AI with your recipe.'**
  String get aiPromptCopied;

  /// No description provided for @aiLoadJsonFile.
  ///
  /// In en, this message translates to:
  /// **'Load .json file'**
  String get aiLoadJsonFile;

  /// No description provided for @aiPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get aiPaste;

  /// No description provided for @aiTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get aiTipsTitle;

  /// No description provided for @aiTip1.
  ///
  /// In en, this message translates to:
  /// **'Works with ChatGPT, Claude, Gemini, Copilot, or any AI'**
  String get aiTip1;

  /// No description provided for @aiTip2.
  ///
  /// In en, this message translates to:
  /// **'You can also take a photo of a recipe and paste it with the prompt'**
  String get aiTip2;

  /// No description provided for @aiTip3.
  ///
  /// In en, this message translates to:
  /// **'The AI will convert handwritten, printed, or web recipes'**
  String get aiTip3;

  /// No description provided for @aiTip4.
  ///
  /// In en, this message translates to:
  /// **'If the JSON has errors, try telling the AI to fix it'**
  String get aiTip4;

  /// No description provided for @aiServingsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} servings'**
  String aiServingsLabel(String count);

  /// No description provided for @aiPrepLabel.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m prep'**
  String aiPrepLabel(String minutes);

  /// No description provided for @aiCookLabel.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m cook'**
  String aiCookLabel(String minutes);

  /// No description provided for @aiIngredientsCount.
  ///
  /// In en, this message translates to:
  /// **'Ingredients ({count})'**
  String aiIngredientsCount(int count);

  /// No description provided for @aiStepsCount.
  ///
  /// In en, this message translates to:
  /// **'Steps ({count})'**
  String aiStepsCount(int count);

  /// No description provided for @restoreAllWarnings.
  ///
  /// In en, this message translates to:
  /// **'Restore All Warnings'**
  String get restoreAllWarnings;

  /// No description provided for @warningsRestoredForRecipe.
  ///
  /// In en, this message translates to:
  /// **'Warnings restored for recipe'**
  String get warningsRestoredForRecipe;

  /// No description provided for @restoreAllWarningsQuestion.
  ///
  /// In en, this message translates to:
  /// **'Restore All Warnings?'**
  String get restoreAllWarningsQuestion;

  /// No description provided for @restoreAll.
  ///
  /// In en, this message translates to:
  /// **'Restore All'**
  String get restoreAll;

  /// No description provided for @allWarningsRestored.
  ///
  /// In en, this message translates to:
  /// **'All warnings restored'**
  String get allWarningsRestored;

  /// No description provided for @dismissedWarnings.
  ///
  /// In en, this message translates to:
  /// **'{count} dismissed'**
  String dismissedWarnings(int count);

  /// No description provided for @restoringPurchases.
  ///
  /// In en, this message translates to:
  /// **'Restoring purchases...'**
  String get restoringPurchases;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restorePurchases;

  /// No description provided for @compareAllPlans.
  ///
  /// In en, this message translates to:
  /// **'Compare all plans'**
  String get compareAllPlans;

  /// No description provided for @oneTimeTab.
  ///
  /// In en, this message translates to:
  /// **'One-Time'**
  String get oneTimeTab;

  /// No description provided for @subscriptionTab.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscriptionTab;

  /// No description provided for @payOnceKeepForever.
  ///
  /// In en, this message translates to:
  /// **'Pay once, keep forever'**
  String get payOnceKeepForever;

  /// No description provided for @cloudSyncFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Try free for 1 week'**
  String get cloudSyncFreeTrial;

  /// No description provided for @subscribeCloudSyncMonthlyTrialCta.
  ///
  /// In en, this message translates to:
  /// **'Start free trial — then \$2.99/mo'**
  String get subscribeCloudSyncMonthlyTrialCta;

  /// No description provided for @subscribeCloudSyncYearlyTrialCta.
  ///
  /// In en, this message translates to:
  /// **'Start free trial — then \$29.99/yr'**
  String get subscribeCloudSyncYearlyTrialCta;

  /// No description provided for @cloudSyncFeature.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get cloudSyncFeature;

  /// No description provided for @cloudSyncFamilyFeature.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync Family'**
  String get cloudSyncFamilyFeature;

  /// No description provided for @unableToLoadProducts.
  ///
  /// In en, this message translates to:
  /// **'Unable to load products. Try again.'**
  String get unableToLoadProducts;

  /// No description provided for @noOfferingsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No offerings available. Try again later.'**
  String get noOfferingsAvailable;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed: {error}'**
  String purchaseFailed(String error);

  /// No description provided for @hintProductExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., Organic Pasta Sauce'**
  String get hintProductExample;

  /// No description provided for @previewPhoto.
  ///
  /// In en, this message translates to:
  /// **'Preview Photo'**
  String get previewPhoto;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @usePhoto.
  ///
  /// In en, this message translates to:
  /// **'Use Photo'**
  String get usePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @removeImage.
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get removeImage;

  /// No description provided for @tipsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tips, variations, storage instructions...'**
  String get tipsPlaceholder;

  /// No description provided for @totalCalories.
  ///
  /// In en, this message translates to:
  /// **'Total cal'**
  String get totalCalories;

  /// No description provided for @caloriesPerServing.
  ///
  /// In en, this message translates to:
  /// **'Cal/serving'**
  String get caloriesPerServing;

  /// No description provided for @totalNutrition.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalNutrition;

  /// No description provided for @linkRecipe.
  ///
  /// In en, this message translates to:
  /// **'Link Recipe'**
  String get linkRecipe;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get addIngredient;

  /// No description provided for @searchRecipesToLink.
  ///
  /// In en, this message translates to:
  /// **'Search recipes to link...'**
  String get searchRecipesToLink;

  /// No description provided for @linkToIngredient.
  ///
  /// In en, this message translates to:
  /// **'Link to \"{name}\"'**
  String linkToIngredient(String name);

  /// No description provided for @errorSavingRecipe.
  ///
  /// In en, this message translates to:
  /// **'Error saving recipe: {error}'**
  String errorSavingRecipe(String error);

  /// No description provided for @deleteSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'Delete {count}'**
  String deleteSelectedCount(int count);

  /// No description provided for @takeAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takeAPhoto;

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @scaleRecipe.
  ///
  /// In en, this message translates to:
  /// **'Scale Recipe'**
  String get scaleRecipe;

  /// No description provided for @scaleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 2.5'**
  String get scaleHint;

  /// No description provided for @badgePinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get badgePinned;

  /// No description provided for @badgeRecentlyViewed.
  ///
  /// In en, this message translates to:
  /// **'Recently Viewed'**
  String get badgeRecentlyViewed;

  /// No description provided for @displayOptions.
  ///
  /// In en, this message translates to:
  /// **'Display Options'**
  String get displayOptions;

  /// No description provided for @showMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Show Meal Plan'**
  String get showMealPlan;

  /// No description provided for @showMealPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display today\'s scheduled recipes'**
  String get showMealPlanSubtitle;

  /// No description provided for @showPinnedRecipes.
  ///
  /// In en, this message translates to:
  /// **'Show Pinned Recipes'**
  String get showPinnedRecipes;

  /// No description provided for @showPinnedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display recipes you\'ve pinned'**
  String get showPinnedSubtitle;

  /// No description provided for @showRecentHistory.
  ///
  /// In en, this message translates to:
  /// **'Show Recent History'**
  String get showRecentHistory;

  /// No description provided for @showRecentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display recently viewed recipes'**
  String get showRecentSubtitle;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @measurementsUS.
  ///
  /// In en, this message translates to:
  /// **'cups, tablespoons, ounces, °F'**
  String get measurementsUS;

  /// No description provided for @measurementsMetric.
  ///
  /// In en, this message translates to:
  /// **'milliliters, grams, °C'**
  String get measurementsMetric;

  /// No description provided for @defaultRecipesImported.
  ///
  /// In en, this message translates to:
  /// **'{count} default recipes imported!'**
  String defaultRecipesImported(int count);

  /// No description provided for @shoppingListGeneratorTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping List Generator'**
  String get shoppingListGeneratorTitle;

  /// No description provided for @exitShoppingListGeneratorQuestion.
  ///
  /// In en, this message translates to:
  /// **'Exit Shopping List Generator?'**
  String get exitShoppingListGeneratorQuestion;

  /// No description provided for @reviewAndAddItems.
  ///
  /// In en, this message translates to:
  /// **'Review & Add ({count} items)'**
  String reviewAndAddItems(int count);

  /// No description provided for @addedTotalItemsToList.
  ///
  /// In en, this message translates to:
  /// **'Added {count} items to shopping list'**
  String addedTotalItemsToList(int count);

  /// No description provided for @scaleMultiplier.
  ///
  /// In en, this message translates to:
  /// **'{scale}x'**
  String scaleMultiplier(String scale);

  /// No description provided for @printIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get printIngredients;

  /// No description provided for @printInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get printInstructions;

  /// No description provided for @printNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get printNotes;

  /// No description provided for @printPrep.
  ///
  /// In en, this message translates to:
  /// **'Prep: {minutes} min'**
  String printPrep(int minutes);

  /// No description provided for @printCook.
  ///
  /// In en, this message translates to:
  /// **'Cook: {minutes} min'**
  String printCook(int minutes);

  /// No description provided for @printFooter.
  ///
  /// In en, this message translates to:
  /// **'Printed from Recipe Spellbook'**
  String get printFooter;

  /// No description provided for @printPage.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String printPage(int current, int total);

  /// No description provided for @menuNavigation.
  ///
  /// In en, this message translates to:
  /// **'NAVIGATION'**
  String get menuNavigation;

  /// No description provided for @menuImport.
  ///
  /// In en, this message translates to:
  /// **'IMPORT'**
  String get menuImport;

  /// No description provided for @menuKitchenBuddyMode.
  ///
  /// In en, this message translates to:
  /// **'KITCHEN BUDDY'**
  String get menuKitchenBuddyMode;

  /// No description provided for @menuSocial.
  ///
  /// In en, this message translates to:
  /// **'SOCIAL'**
  String get menuSocial;

  /// No description provided for @menuApp.
  ///
  /// In en, this message translates to:
  /// **'APP'**
  String get menuApp;

  /// No description provided for @historyCount.
  ///
  /// In en, this message translates to:
  /// **'History Count'**
  String get historyCount;

  /// No description provided for @historyCountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Maximum number of recent recipes to show'**
  String get historyCountSubtitle;

  /// No description provided for @restoreAllWarningsDesc.
  ///
  /// In en, this message translates to:
  /// **'This will re-enable allergy warnings for all recipes. You will start seeing warnings again when viewing these recipes.'**
  String get restoreAllWarningsDesc;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @signInForPurchaseDesc.
  ///
  /// In en, this message translates to:
  /// **'An account is required before purchasing so your subscription stays linked across devices.'**
  String get signInForPurchaseDesc;

  /// No description provided for @menuAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get menuAchievements;

  /// No description provided for @menuLeaderboards.
  ///
  /// In en, this message translates to:
  /// **'Leaderboards'**
  String get menuLeaderboards;

  /// No description provided for @requiresPremium.
  ///
  /// In en, this message translates to:
  /// **'Requires Premium'**
  String get requiresPremium;

  /// No description provided for @deleteCount.
  ///
  /// In en, this message translates to:
  /// **'Delete {count}'**
  String deleteCount(int count);

  /// No description provided for @tapToSelectPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to select from gallery or camera'**
  String get tapToSelectPhoto;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @usUnits.
  ///
  /// In en, this message translates to:
  /// **'cups, tablespoons, ounces, °F'**
  String get usUnits;

  /// No description provided for @metricUnits.
  ///
  /// In en, this message translates to:
  /// **'milliliters, grams, °C'**
  String get metricUnits;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @deleteRecipesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} recipe(s)?'**
  String deleteRecipesConfirm(int count);

  /// No description provided for @courseSetForRecipes.
  ///
  /// In en, this message translates to:
  /// **'Course set for {count} recipe(s)'**
  String courseSetForRecipes(int count);

  /// No description provided for @recipeImportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Recipe imported successfully!'**
  String get recipeImportedSuccess;

  /// No description provided for @promptCopied.
  ///
  /// In en, this message translates to:
  /// **'Prompt copied! Paste it into any AI with your recipe.'**
  String get promptCopied;

  /// No description provided for @importFromAI.
  ///
  /// In en, this message translates to:
  /// **'Import from AI'**
  String get importFromAI;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @previewAndImport.
  ///
  /// In en, this message translates to:
  /// **'Preview & Import'**
  String get previewAndImport;

  /// No description provided for @signInDescription.
  ///
  /// In en, this message translates to:
  /// **'Back up your recipes, sync across devices, and unlock premium features.'**
  String get signInDescription;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Your recipes stay on this device. You can sign back in anytime to re-enable sync.'**
  String get signOutConfirmMessage;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and all synced data from our servers.\n\nRecipes stored locally on this device will NOT be deleted.'**
  String get deleteAccountConfirmMessage;

  /// No description provided for @planLabel.
  ///
  /// In en, this message translates to:
  /// **'{label} Plan'**
  String planLabel(String label);

  /// No description provided for @permanentlyDeleteWarning.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete {scope}. This cannot be undone.'**
  String permanentlyDeleteWarning(String scope);

  /// No description provided for @recipesMovedToTrash.
  ///
  /// In en, this message translates to:
  /// **'{count} recipe(s) moved to trash'**
  String recipesMovedToTrash(int count);

  /// No description provided for @recipesFavorited.
  ///
  /// In en, this message translates to:
  /// **'{count} recipe(s) favorited'**
  String recipesFavorited(int count);

  /// No description provided for @upgradeRecipeSpellbook.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Recipe Spellbook'**
  String get upgradeRecipeSpellbook;

  /// No description provided for @choosePlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the plan that fits your kitchen'**
  String get choosePlanSubtitle;

  /// No description provided for @premiumInfoNotice.
  ///
  /// In en, this message translates to:
  /// **'Premium is a one-time purchase that enhances your free experience. It does not include family sharing or advanced cloud features — see Subscriptions for those.'**
  String get premiumInfoNotice;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get bestValue;

  /// No description provided for @billedMonthly.
  ///
  /// In en, this message translates to:
  /// **'Billed monthly'**
  String get billedMonthly;

  /// No description provided for @save16Yearly.
  ///
  /// In en, this message translates to:
  /// **'Save 16% — only \$2.50/mo'**
  String get save16Yearly;

  /// No description provided for @save16Badge.
  ///
  /// In en, this message translates to:
  /// **'SAVE 16%'**
  String get save16Badge;

  /// No description provided for @save17Yearly.
  ///
  /// In en, this message translates to:
  /// **'Save 17% — only \$4.17/mo'**
  String get save17Yearly;

  /// No description provided for @subscriptionsIncludePremium.
  ///
  /// In en, this message translates to:
  /// **'All subscriptions include everything in Premium.'**
  String get subscriptionsIncludePremium;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @purchasePremiumCta.
  ///
  /// In en, this message translates to:
  /// **'Purchase Premium — \$6.99'**
  String get purchasePremiumCta;

  /// No description provided for @subscribeCloudSyncMonthlyCta.
  ///
  /// In en, this message translates to:
  /// **'Subscribe — \$2.99/mo'**
  String get subscribeCloudSyncMonthlyCta;

  /// No description provided for @subscribeCloudSyncYearlyCta.
  ///
  /// In en, this message translates to:
  /// **'Subscribe — \$29.99/yr'**
  String get subscribeCloudSyncYearlyCta;

  /// No description provided for @subscribeCloudSyncPlusMonthlyCta.
  ///
  /// In en, this message translates to:
  /// **'Subscribe — \$4.99/mo'**
  String get subscribeCloudSyncPlusMonthlyCta;

  /// No description provided for @subscribeCloudSyncPlusYearlyCta.
  ///
  /// In en, this message translates to:
  /// **'Subscribe — \$49.99/yr'**
  String get subscribeCloudSyncPlusYearlyCta;

  /// No description provided for @signInRequiredBeforePurchase.
  ///
  /// In en, this message translates to:
  /// **'Sign-in required before purchase'**
  String get signInRequiredBeforePurchase;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @comparePlans.
  ///
  /// In en, this message translates to:
  /// **'Compare Plans'**
  String get comparePlans;

  /// No description provided for @featureCloudSyncPersonal.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync (personal)'**
  String get featureCloudSyncPersonal;

  /// No description provided for @featurePhotosOnSteps.
  ///
  /// In en, this message translates to:
  /// **'Photos on steps'**
  String get featurePhotosOnSteps;

  /// No description provided for @featureCloudStorageLimited.
  ///
  /// In en, this message translates to:
  /// **'Cloud storage — Limited'**
  String get featureCloudStorageLimited;

  /// No description provided for @featureSmartImport.
  ///
  /// In en, this message translates to:
  /// **'AI Smart Import'**
  String get featureSmartImport;

  /// No description provided for @featureFamilySharing5.
  ///
  /// In en, this message translates to:
  /// **'Family sharing (5 members)'**
  String get featureFamilySharing5;

  /// No description provided for @featureCloudStorage.
  ///
  /// In en, this message translates to:
  /// **'Cloud storage'**
  String get featureCloudStorage;

  /// No description provided for @featureSharedLists.
  ///
  /// In en, this message translates to:
  /// **'Shared shopping lists'**
  String get featureSharedLists;

  /// No description provided for @featureSharedCookbooks.
  ///
  /// In en, this message translates to:
  /// **'Shared cookbooks'**
  String get featureSharedCookbooks;

  /// No description provided for @featureSharedMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Shared meal planning'**
  String get featureSharedMealPlan;

  /// No description provided for @featureAutoBackups.
  ///
  /// In en, this message translates to:
  /// **'Automatic backups'**
  String get featureAutoBackups;

  /// No description provided for @featureFamilySharing10.
  ///
  /// In en, this message translates to:
  /// **'Family sharing (10 members)'**
  String get featureFamilySharing10;

  /// No description provided for @featurePrioritySync.
  ///
  /// In en, this message translates to:
  /// **'Priority sync performance'**
  String get featurePrioritySync;

  /// No description provided for @featureFutureAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Future advanced features included'**
  String get featureFutureAdvanced;

  /// No description provided for @tierCloudSync.
  ///
  /// In en, this message translates to:
  /// **'CLOUD SYNC'**
  String get tierCloudSync;

  /// No description provided for @tierCloudSyncPlus.
  ///
  /// In en, this message translates to:
  /// **'Cloud\nSync+'**
  String get tierCloudSyncPlus;

  /// No description provided for @comparePrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get comparePrice;

  /// No description provided for @priceFree.
  ///
  /// In en, this message translates to:
  /// **'\$0'**
  String get priceFree;

  /// No description provided for @pricePremium.
  ///
  /// In en, this message translates to:
  /// **'\$6.99\nonce'**
  String get pricePremium;

  /// No description provided for @priceCloudSync.
  ///
  /// In en, this message translates to:
  /// **'\$2.99\n/mo'**
  String get priceCloudSync;

  /// No description provided for @priceCloudSyncPlus.
  ///
  /// In en, this message translates to:
  /// **'\$4.99\n/mo'**
  String get priceCloudSyncPlus;

  /// No description provided for @compareDeviceTransfer.
  ///
  /// In en, this message translates to:
  /// **'Device transfer'**
  String get compareDeviceTransfer;

  /// No description provided for @qrCode.
  ///
  /// In en, this message translates to:
  /// **'QR code'**
  String get qrCode;

  /// No description provided for @cloud.
  ///
  /// In en, this message translates to:
  /// **'Cloud'**
  String get cloud;

  /// No description provided for @comparePhotoStorage.
  ///
  /// In en, this message translates to:
  /// **'Photo storage'**
  String get comparePhotoStorage;

  /// No description provided for @compareStepPhotos.
  ///
  /// In en, this message translates to:
  /// **'Step photos'**
  String get compareStepPhotos;

  /// No description provided for @compareFamilySharing.
  ///
  /// In en, this message translates to:
  /// **'Family sharing'**
  String get compareFamilySharing;

  /// No description provided for @compareSharedLists.
  ///
  /// In en, this message translates to:
  /// **'Shared lists'**
  String get compareSharedLists;

  /// No description provided for @compareSharedCookbooks.
  ///
  /// In en, this message translates to:
  /// **'Shared cookbooks'**
  String get compareSharedCookbooks;

  /// No description provided for @compareSharedMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Shared meal plan'**
  String get compareSharedMealPlan;

  /// No description provided for @compareBackups.
  ///
  /// In en, this message translates to:
  /// **'Backups'**
  String get compareBackups;

  /// No description provided for @compareSmartImport.
  ///
  /// In en, this message translates to:
  /// **'AI Smart Import'**
  String get compareSmartImport;

  /// No description provided for @compareSmartImportNone.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get compareSmartImportNone;

  /// No description provided for @compareSmartImportPremium.
  ///
  /// In en, this message translates to:
  /// **'Trial'**
  String get compareSmartImportPremium;

  /// No description provided for @compareSmartImportCloud.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get compareSmartImportCloud;

  /// No description provided for @compareCloudStorage.
  ///
  /// In en, this message translates to:
  /// **'Cloud Storage'**
  String get compareCloudStorage;

  /// No description provided for @compareCloudStorageBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get compareCloudStorageBasic;

  /// No description provided for @compareCloudStorageStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get compareCloudStorageStandard;

  /// No description provided for @compareCloudStorageExtended.
  ///
  /// In en, this message translates to:
  /// **'Extended'**
  String get compareCloudStorageExtended;

  /// No description provided for @printOf.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get printOf;

  /// No description provided for @printRecipe.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get printRecipe;

  /// No description provided for @stackedLayout.
  ///
  /// In en, this message translates to:
  /// **'Stacked Layout'**
  String get stackedLayout;

  /// No description provided for @tabbedLayout.
  ///
  /// In en, this message translates to:
  /// **'Tabbed Layout'**
  String get tabbedLayout;

  /// No description provided for @printLabelIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get printLabelIngredients;

  /// No description provided for @printLabelInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get printLabelInstructions;

  /// No description provided for @printLabelNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get printLabelNotes;

  /// No description provided for @printLabelPrep.
  ///
  /// In en, this message translates to:
  /// **'Prep'**
  String get printLabelPrep;

  /// No description provided for @printLabelCook.
  ///
  /// In en, this message translates to:
  /// **'Cook'**
  String get printLabelCook;

  /// No description provided for @printLabelFooter.
  ///
  /// In en, this message translates to:
  /// **'Printed from Recipe Spellbook'**
  String get printLabelFooter;

  /// No description provided for @printLabelPage.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get printLabelPage;

  /// No description provided for @printLabelOf.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get printLabelOf;

  /// No description provided for @smallerText.
  ///
  /// In en, this message translates to:
  /// **'Smaller text'**
  String get smallerText;

  /// No description provided for @largerText.
  ///
  /// In en, this message translates to:
  /// **'Larger text'**
  String get largerText;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get textSize;

  /// No description provided for @ingredientPreview.
  ///
  /// In en, this message translates to:
  /// **'Ingredient Preview'**
  String get ingredientPreview;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get resetToDefault;

  /// No description provided for @smartImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Recipe re-parsed by AI'**
  String get smartImportSuccess;

  /// No description provided for @smartImportSuccessWithRemaining.
  ///
  /// In en, this message translates to:
  /// **'Recipe re-parsed by AI • {remaining} imports left this month'**
  String smartImportSuccessWithRemaining(int remaining);

  /// No description provided for @smartImportLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Import Limit Reached'**
  String get smartImportLimitTitle;

  /// No description provided for @smartImportLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'\'ve used all {limit} smart imports this month.'**
  String smartImportLimitMessage(int limit);

  /// No description provided for @smartImportUpgradeHint.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium for 200 imports/month.'**
  String get smartImportUpgradeHint;

  /// No description provided for @smartImportParsing.
  ///
  /// In en, this message translates to:
  /// **'AI is parsing...'**
  String get smartImportParsing;

  /// No description provided for @smartImportFix.
  ///
  /// In en, this message translates to:
  /// **'Fix with Smart Import ✨'**
  String get smartImportFix;

  /// No description provided for @smartImportRemaining.
  ///
  /// In en, this message translates to:
  /// **'{remaining} of {limit} smart imports remaining this month'**
  String smartImportRemaining(int remaining, int limit);

  /// No description provided for @smartImportHintTitle.
  ///
  /// In en, this message translates to:
  /// **'Import not looking right?'**
  String get smartImportHintTitle;

  /// No description provided for @smartImportHintSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Subscribe for Smart Import — AI-powered recipe parsing'**
  String get smartImportHintSubtitle;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get learnMore;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @cookingMode.
  ///
  /// In en, this message translates to:
  /// **'Cooking Mode'**
  String get cookingMode;

  /// No description provided for @mealTypeDessert.
  ///
  /// In en, this message translates to:
  /// **'Dessert'**
  String get mealTypeDessert;

  /// No description provided for @noContentToSave.
  ///
  /// In en, this message translates to:
  /// **'No content to save'**
  String get noContentToSave;

  /// No description provided for @recipeSaved.
  ///
  /// In en, this message translates to:
  /// **'Recipe saved!'**
  String get recipeSaved;

  /// No description provided for @qrScanningMobileOnly.
  ///
  /// In en, this message translates to:
  /// **'QR scanning is only available on mobile devices.'**
  String get qrScanningMobileOnly;

  /// No description provided for @communityComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Community features coming in a future update!'**
  String get communityComingSoon;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {error}'**
  String somethingWentWrong(String error);

  /// No description provided for @starterRecipesAdded.
  ///
  /// In en, this message translates to:
  /// **'Added {count} starter recipes! 🎉'**
  String starterRecipesAdded(int count);

  /// No description provided for @enterAtLeastOneNutrient.
  ///
  /// In en, this message translates to:
  /// **'Enter at least calories or one macro nutrient'**
  String get enterAtLeastOneNutrient;

  /// No description provided for @addedToMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Added to {mealType} on {date}'**
  String addedToMealPlan(String mealType, String date);

  /// No description provided for @noItemsFoundInText.
  ///
  /// In en, this message translates to:
  /// **'No items found in text'**
  String get noItemsFoundInText;

  /// No description provided for @noTextFoundInImage.
  ///
  /// In en, this message translates to:
  /// **'No text found in image'**
  String get noTextFoundInImage;

  /// No description provided for @addDayToShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Add day to shopping list'**
  String get addDayToShoppingList;

  /// No description provided for @sendDayToShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Send day to shopping list'**
  String get sendDayToShoppingList;

  /// No description provided for @removeMeal.
  ///
  /// In en, this message translates to:
  /// **'Remove Meal'**
  String get removeMeal;

  /// No description provided for @removeMealConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {recipeName} from this day?'**
  String removeMealConfirm(String recipeName);

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @plannerMealRemoved.
  ///
  /// In en, this message translates to:
  /// **'Meal removed'**
  String get plannerMealRemoved;

  /// No description provided for @weekStartsOn.
  ///
  /// In en, this message translates to:
  /// **'Week starts on'**
  String get weekStartsOn;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @ingredientHeader.
  ///
  /// In en, this message translates to:
  /// **'Header'**
  String get ingredientHeader;

  /// No description provided for @ingredientHeaderHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., For the sauce'**
  String get ingredientHeaderHint;

  /// No description provided for @settingsWeekStartDay.
  ///
  /// In en, this message translates to:
  /// **'Week starts on'**
  String get settingsWeekStartDay;

  /// No description provided for @settingsSurpriseMe.
  ///
  /// In en, this message translates to:
  /// **'Show \'Surprise Me\' card'**
  String get settingsSurpriseMe;

  /// No description provided for @settingsSurpriseMeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show recipe suggestion card on home screen'**
  String get settingsSurpriseMeSubtitle;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotifCooking.
  ///
  /// In en, this message translates to:
  /// **'Cooking Reminders'**
  String get settingsNotifCooking;

  /// No description provided for @settingsNotifCookingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Meal plan alerts and cooking reminders'**
  String get settingsNotifCookingSubtitle;

  /// No description provided for @settingsNotifCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community Updates'**
  String get settingsNotifCommunity;

  /// No description provided for @settingsNotifCommunitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Downloads, ratings, and comments on your recipes'**
  String get settingsNotifCommunitySubtitle;

  /// No description provided for @settingsNotifAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get settingsNotifAchievements;

  /// No description provided for @settingsNotifAchievementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Achievement unlocks and milestone alerts'**
  String get settingsNotifAchievementsSubtitle;

  /// No description provided for @settingsNotifBuddy.
  ///
  /// In en, this message translates to:
  /// **'Buddy Reminders'**
  String get settingsNotifBuddy;

  /// No description provided for @settingsNotifBuddySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Kitchen Buddy login streaks and coin bonuses'**
  String get settingsNotifBuddySubtitle;

  /// No description provided for @settingsNotifManagePreferences.
  ///
  /// In en, this message translates to:
  /// **'Manage notification preferences'**
  String get settingsNotifManagePreferences;

  /// No description provided for @settingsNotifNewDownloads.
  ///
  /// In en, this message translates to:
  /// **'New downloads'**
  String get settingsNotifNewDownloads;

  /// No description provided for @settingsNotifNewDownloadsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When someone downloads your published recipe'**
  String get settingsNotifNewDownloadsSubtitle;

  /// No description provided for @settingsNotifRatingUpdates.
  ///
  /// In en, this message translates to:
  /// **'Rating updates'**
  String get settingsNotifRatingUpdates;

  /// No description provided for @settingsNotifRatingUpdatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When your published recipe gets a new rating'**
  String get settingsNotifRatingUpdatesSubtitle;

  /// No description provided for @settingsNotifComments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get settingsNotifComments;

  /// No description provided for @settingsNotifCommentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When someone comments on your recipe'**
  String get settingsNotifCommentsSubtitle;

  /// No description provided for @settingsNotifSyncNote.
  ///
  /// In en, this message translates to:
  /// **'Notification preferences are synced with your account.'**
  String get settingsNotifSyncNote;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @shoppingAddedToList.
  ///
  /// In en, this message translates to:
  /// **'Added {count} {count, plural, =1{item} other{items}} to \"{listName}\"'**
  String shoppingAddedToList(int count, String listName);

  /// No description provided for @shoppingAddedAndCombined.
  ///
  /// In en, this message translates to:
  /// **'Added {added} {added, plural, =1{item} other{items}} to \"{listName}\", {combined} combined'**
  String shoppingAddedAndCombined(int added, int combined, String listName);

  /// No description provided for @shoppingItemsUpdated.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{item} other{items}} updated on \"{listName}\"'**
  String shoppingItemsUpdated(int count, String listName);

  /// No description provided for @shoppingAddError.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String shoppingAddError(String message);

  /// No description provided for @editCookbook.
  ///
  /// In en, this message translates to:
  /// **'Edit Cookbook'**
  String get editCookbook;

  /// No description provided for @newCookbook.
  ///
  /// In en, this message translates to:
  /// **'New Cookbook'**
  String get newCookbook;

  /// No description provided for @tapToAddCoverImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to add cover image'**
  String get tapToAddCoverImage;

  /// No description provided for @cookbookDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get cookbookDescriptionLabel;

  /// No description provided for @cookbookDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'A collection of recipes...'**
  String get cookbookDescriptionHint;

  /// No description provided for @cookbookNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get cookbookNameRequired;

  /// No description provided for @addCover.
  ///
  /// In en, this message translates to:
  /// **'Add Cover'**
  String get addCover;

  /// No description provided for @recipeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{recipe} other{recipes}}'**
  String recipeCount(int count);

  /// No description provided for @cookbookDeleteWithRecipes.
  ///
  /// In en, this message translates to:
  /// **'This cookbook contains {count} {count, plural, =1{recipe} other{recipes}}. They will be moved to trash.\n\nAre you sure you want to delete \"{name}\"?'**
  String cookbookDeleteWithRecipes(int count, String name);

  /// No description provided for @cookbookDeleteConfirmNamed.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String cookbookDeleteConfirmNamed(String name);

  /// No description provided for @shareCookbook.
  ///
  /// In en, this message translates to:
  /// **'Share Cookbook'**
  String get shareCookbook;

  /// No description provided for @cookbookEmpty.
  ///
  /// In en, this message translates to:
  /// **'This cookbook has no recipes to share'**
  String get cookbookEmpty;

  /// No description provided for @recipes.
  ///
  /// In en, this message translates to:
  /// **'recipes'**
  String get recipes;

  /// No description provided for @sendSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Send a Suggestion'**
  String get sendSuggestion;

  /// No description provided for @sendSuggestionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help us improve Recipe Spellbook'**
  String get sendSuggestionSubtitle;

  /// No description provided for @reportBug.
  ///
  /// In en, this message translates to:
  /// **'Report a Bug'**
  String get reportBug;

  /// No description provided for @reportBugSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Something not working right?'**
  String get reportBugSubtitle;

  /// No description provided for @joinDiscord.
  ///
  /// In en, this message translates to:
  /// **'Join our Discord'**
  String get joinDiscord;

  /// No description provided for @joinDiscordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get help, chat, and share recipes'**
  String get joinDiscordSubtitle;

  /// No description provided for @actionSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get actionSend;

  /// No description provided for @suggestionDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'d love to hear your ideas! Your suggestion will be sent directly to our team.'**
  String get suggestionDescription;

  /// No description provided for @suggestionTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Suggestion Title'**
  String get suggestionTitleLabel;

  /// No description provided for @suggestionTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Add dark mode for cooking screen'**
  String get suggestionTitleHint;

  /// No description provided for @suggestionDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get suggestionDetailsLabel;

  /// No description provided for @suggestionDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your idea in detail...'**
  String get suggestionDetailsHint;

  /// No description provided for @contactOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact (optional)'**
  String get contactOptionalLabel;

  /// No description provided for @contactOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'Email or Discord username'**
  String get contactOptionalHint;

  /// No description provided for @suggestionSent.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Your suggestion has been sent 💡'**
  String get suggestionSent;

  /// No description provided for @bugDescription.
  ///
  /// In en, this message translates to:
  /// **'Found a bug? Let us know and we\'ll squash it. Device info is included automatically.'**
  String get bugDescription;

  /// No description provided for @bugTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Bug Title'**
  String get bugTitleLabel;

  /// No description provided for @bugTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., App crashes when importing PDF'**
  String get bugTitleHint;

  /// No description provided for @bugDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get bugDetailsLabel;

  /// No description provided for @bugDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what went wrong...'**
  String get bugDetailsHint;

  /// No description provided for @bugStepsLabel.
  ///
  /// In en, this message translates to:
  /// **'Steps to Reproduce (optional)'**
  String get bugStepsLabel;

  /// No description provided for @bugStepsHint.
  ///
  /// In en, this message translates to:
  /// **'1. Open recipe\n2. Tap share\n3. App crashes'**
  String get bugStepsHint;

  /// No description provided for @bugReportSent.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Your bug report has been sent 🐛'**
  String get bugReportSent;

  /// No description provided for @feedbackFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the title and details'**
  String get feedbackFieldsRequired;

  /// No description provided for @feedbackSendError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send feedback. Check your internet connection.'**
  String get feedbackSendError;

  /// No description provided for @mealTypeAppetizer.
  ///
  /// In en, this message translates to:
  /// **'Appetizer'**
  String get mealTypeAppetizer;

  /// No description provided for @allergenContains.
  ///
  /// In en, this message translates to:
  /// **'Contains'**
  String get allergenContains;

  /// No description provided for @settingsIngredientLayout.
  ///
  /// In en, this message translates to:
  /// **'Ingredient Layout'**
  String get settingsIngredientLayout;

  /// No description provided for @ingredientLayoutInline.
  ///
  /// In en, this message translates to:
  /// **'Inline — 1 tsp butter'**
  String get ingredientLayoutInline;

  /// No description provided for @ingredientLayoutColumnar.
  ///
  /// In en, this message translates to:
  /// **'Columnar — amounts aligned'**
  String get ingredientLayoutColumnar;

  /// No description provided for @settingsIngredientLayoutDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how ingredient amounts and names are displayed in recipes, shopping lists, and print.'**
  String get settingsIngredientLayoutDescription;

  /// No description provided for @ingredientLayoutInlineDescription.
  ///
  /// In en, this message translates to:
  /// **'Amount, unit, and name flow together naturally'**
  String get ingredientLayoutInlineDescription;

  /// No description provided for @ingredientLayoutColumnarDescription.
  ///
  /// In en, this message translates to:
  /// **'Amounts aligned in a fixed column for easy scanning'**
  String get ingredientLayoutColumnarDescription;

  /// No description provided for @ingredientLayoutInfoText.
  ///
  /// In en, this message translates to:
  /// **'This setting applies to recipe view, shopping list generator, and printed recipes.'**
  String get ingredientLayoutInfoText;

  /// No description provided for @searchCookbooks.
  ///
  /// In en, this message translates to:
  /// **'Search cookbooks...'**
  String get searchCookbooks;

  /// No description provided for @aboutWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get aboutWebsite;

  /// No description provided for @aboutPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get aboutPrivacyPolicy;

  /// No description provided for @aboutPrivacyPolicySub.
  ///
  /// In en, this message translates to:
  /// **'How we handle your data'**
  String get aboutPrivacyPolicySub;

  /// No description provided for @aboutTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get aboutTermsOfService;

  /// No description provided for @aboutTermsOfServiceSub.
  ///
  /// In en, this message translates to:
  /// **'Usage terms and conditions'**
  String get aboutTermsOfServiceSub;

  /// No description provided for @aboutCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get aboutCommunity;

  /// No description provided for @aboutCommunitySub.
  ///
  /// In en, this message translates to:
  /// **'Join our Discord server'**
  String get aboutCommunitySub;

  /// No description provided for @aboutReportBug.
  ///
  /// In en, this message translates to:
  /// **'Report a Bug'**
  String get aboutReportBug;

  /// No description provided for @aboutReportBugSub.
  ///
  /// In en, this message translates to:
  /// **'Help us improve the app'**
  String get aboutReportBugSub;

  /// No description provided for @aboutRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get aboutRateApp;

  /// No description provided for @aboutRateAppSub.
  ///
  /// In en, this message translates to:
  /// **'Leave a review on the store'**
  String get aboutRateAppSub;

  /// No description provided for @aboutLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get aboutLicenses;

  /// No description provided for @aboutLicensesSub.
  ///
  /// In en, this message translates to:
  /// **'Third-party software used'**
  String get aboutLicensesSub;

  /// No description provided for @sortOrder.
  ///
  /// In en, this message translates to:
  /// **'Sort Order'**
  String get sortOrder;

  /// No description provided for @ingredientAddHeader.
  ///
  /// In en, this message translates to:
  /// **'Add Header'**
  String get ingredientAddHeader;

  /// No description provided for @saveAsRecipe.
  ///
  /// In en, this message translates to:
  /// **'Save as Recipe'**
  String get saveAsRecipe;

  /// No description provided for @exportFullBackup.
  ///
  /// In en, this message translates to:
  /// **'Full Backup'**
  String get exportFullBackup;

  /// No description provided for @exportCookbooksRecipes.
  ///
  /// In en, this message translates to:
  /// **'Cookbooks & Recipes'**
  String get exportCookbooksRecipes;

  /// No description provided for @exportShoppingLists.
  ///
  /// In en, this message translates to:
  /// **'Shopping Lists'**
  String get exportShoppingLists;

  /// No description provided for @exportMealPlans.
  ///
  /// In en, this message translates to:
  /// **'Meal Plans'**
  String get exportMealPlans;

  /// No description provided for @exportTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get exportTags;

  /// No description provided for @exportCategories.
  ///
  /// In en, this message translates to:
  /// **'Custom Categories'**
  String get exportCategories;

  /// No description provided for @exportCourses.
  ///
  /// In en, this message translates to:
  /// **'Custom Courses'**
  String get exportCourses;

  /// No description provided for @createRecipeManually.
  ///
  /// In en, this message translates to:
  /// **'Or create a recipe manually'**
  String get createRecipeManually;

  /// No description provided for @transferYourRecipes.
  ///
  /// In en, this message translates to:
  /// **'Transfer your recipes'**
  String get transferYourRecipes;

  /// No description provided for @transferUpgradeBanner.
  ///
  /// In en, this message translates to:
  /// **'Want automatic sync? Upgrade to Premium for cloud sync across all your devices.'**
  String get transferUpgradeBanner;

  /// No description provided for @transferCodeLength.
  ///
  /// In en, this message translates to:
  /// **'Code must be 6 characters'**
  String get transferCodeLength;

  /// No description provided for @transferItemRecipes.
  ///
  /// In en, this message translates to:
  /// **'All recipes'**
  String get transferItemRecipes;

  /// No description provided for @transferItemCookbooks.
  ///
  /// In en, this message translates to:
  /// **'Cookbooks & categories'**
  String get transferItemCookbooks;

  /// No description provided for @transferItemMealPlans.
  ///
  /// In en, this message translates to:
  /// **'Meal plans'**
  String get transferItemMealPlans;

  /// No description provided for @transferItemShoppingLists.
  ///
  /// In en, this message translates to:
  /// **'Shopping lists'**
  String get transferItemShoppingLists;

  /// No description provided for @transferItemSettings.
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get transferItemSettings;

  /// No description provided for @transferItemAccount.
  ///
  /// In en, this message translates to:
  /// **'Account sign-in (if sender is logged in)'**
  String get transferItemAccount;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied!'**
  String get codeCopied;

  /// No description provided for @transferTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer Data'**
  String get transferTitle;

  /// No description provided for @transferReceiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a code or scan QR from the sending device'**
  String get transferReceiveSubtitle;

  /// No description provided for @transferPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing your data...'**
  String get transferPreparing;

  /// No description provided for @transferFailed.
  ///
  /// In en, this message translates to:
  /// **'Transfer failed'**
  String get transferFailed;

  /// No description provided for @transferScanDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR on your other device, or enter the code below.'**
  String get transferScanDesc;

  /// No description provided for @transferReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to transfer'**
  String get transferReady;

  /// No description provided for @transferCodeExpires.
  ///
  /// In en, this message translates to:
  /// **'This code expires in 15 minutes'**
  String get transferCodeExpires;

  /// No description provided for @transferComplete.
  ///
  /// In en, this message translates to:
  /// **'Transfer complete!'**
  String get transferComplete;

  /// No description provided for @transferAccountSynced.
  ///
  /// In en, this message translates to:
  /// **'Account signed in from sender'**
  String get transferAccountSynced;

  /// No description provided for @transferScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get transferScanQr;

  /// No description provided for @transferScanQrDesc.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at the QR on the other device'**
  String get transferScanQrDesc;

  /// No description provided for @transferEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter transfer code'**
  String get transferEnterCode;

  /// No description provided for @transferWhatMoves.
  ///
  /// In en, this message translates to:
  /// **'What gets transferred:'**
  String get transferWhatMoves;

  /// No description provided for @transferMergeNote.
  ///
  /// In en, this message translates to:
  /// **'Existing data on this device will be merged. Duplicates are skipped.'**
  String get transferMergeNote;

  /// No description provided for @transferPointCamera.
  ///
  /// In en, this message translates to:
  /// **'Point at the QR code on the sending device'**
  String get transferPointCamera;

  /// No description provided for @labelPrepMin.
  ///
  /// In en, this message translates to:
  /// **'Prep (min)'**
  String get labelPrepMin;

  /// No description provided for @labelCookMin.
  ///
  /// In en, this message translates to:
  /// **'Cook (min)'**
  String get labelCookMin;

  /// No description provided for @labelTotalCal.
  ///
  /// In en, this message translates to:
  /// **'Total cal'**
  String get labelTotalCal;

  /// No description provided for @labelCalPerServing.
  ///
  /// In en, this message translates to:
  /// **'Cal/serving'**
  String get labelCalPerServing;

  /// No description provided for @tooltipViewSize.
  ///
  /// In en, this message translates to:
  /// **'View size'**
  String get tooltipViewSize;

  /// No description provided for @pantryClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear pantry?'**
  String get pantryClearTitle;

  /// No description provided for @pantryAddHint.
  ///
  /// In en, this message translates to:
  /// **'Add item to pantry...'**
  String get pantryAddHint;

  /// No description provided for @pantryAddStaples.
  ///
  /// In en, this message translates to:
  /// **'Add all staples'**
  String get pantryAddStaples;

  /// No description provided for @pantrySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search pantry...'**
  String get pantrySearchHint;

  /// No description provided for @settingsRecipesShopping.
  ///
  /// In en, this message translates to:
  /// **'Recipes & Shopping'**
  String get settingsRecipesShopping;

  /// No description provided for @settingsAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get settingsAdvanced;

  /// No description provided for @settingsAdvancedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tags, courses, categories & more'**
  String get settingsAdvancedSubtitle;

  /// No description provided for @settingsRestoreDefaults.
  ///
  /// In en, this message translates to:
  /// **'Restore Default Recipes'**
  String get settingsRestoreDefaults;

  /// No description provided for @settingsRestoreDefaultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Re-add the 10 starter recipes'**
  String get settingsRestoreDefaultsSubtitle;

  /// No description provided for @settingsRestoreDefaultsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Add 10 starter recipes to your cookbook? Existing recipes won\'t be affected.'**
  String get settingsRestoreDefaultsConfirm;

  /// No description provided for @settingsDeleteData.
  ///
  /// In en, this message translates to:
  /// **'Delete Data'**
  String get settingsDeleteData;

  /// No description provided for @settingsDeleteDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Erase app or cloud data'**
  String get settingsDeleteDataSubtitle;

  /// No description provided for @settingsUpgradeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync, photos & more'**
  String get settingsUpgradeSubtitle;

  /// No description provided for @settingsTextSizeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust text size across the entire app'**
  String get settingsTextSizeSubtitle;

  /// No description provided for @settingsGoogleOrApple.
  ///
  /// In en, this message translates to:
  /// **'Google or Apple'**
  String get settingsGoogleOrApple;

  /// No description provided for @alwaysVisible.
  ///
  /// In en, this message translates to:
  /// **'Always visible'**
  String get alwaysVisible;

  /// No description provided for @chartNumbers.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get chartNumbers;

  /// No description provided for @chartDonut.
  ///
  /// In en, this message translates to:
  /// **'Donut'**
  String get chartDonut;

  /// No description provided for @chartBars.
  ///
  /// In en, this message translates to:
  /// **'Bars'**
  String get chartBars;

  /// No description provided for @unitKcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get unitKcal;

  /// No description provided for @nutritionCustomScale.
  ///
  /// In en, this message translates to:
  /// **'Custom Scale'**
  String get nutritionCustomScale;

  /// No description provided for @nutritionScaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Scale multiplier'**
  String get nutritionScaleLabel;

  /// No description provided for @nutritionScaleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 0.5, 1.5, 3.0'**
  String get nutritionScaleHint;

  /// No description provided for @nutritionSet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get nutritionSet;

  /// No description provided for @nutritionApplyRecalculate.
  ///
  /// In en, this message translates to:
  /// **'Apply & Recalculate'**
  String get nutritionApplyRecalculate;

  /// No description provided for @calAbbrev.
  ///
  /// In en, this message translates to:
  /// **'Cal'**
  String get calAbbrev;

  /// No description provided for @nutritionServingSizeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 1 cup, 100g'**
  String get nutritionServingSizeHint;

  /// No description provided for @shoppingExportList.
  ///
  /// In en, this message translates to:
  /// **'Export list'**
  String get shoppingExportList;

  /// No description provided for @shoppingExportListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share as a text file or backup'**
  String get shoppingExportListSubtitle;

  /// No description provided for @shoppingImportList.
  ///
  /// In en, this message translates to:
  /// **'Import list'**
  String get shoppingImportList;

  /// No description provided for @shoppingImportListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add items from a file, photo, or text'**
  String get shoppingImportListSubtitle;

  /// No description provided for @shoppingScanBarcodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Look up a product to add'**
  String get shoppingScanBarcodeSubtitle;

  /// No description provided for @exportBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Backup file'**
  String get exportBackupFile;

  /// No description provided for @exportBackupFileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For transferring to another device or app'**
  String get exportBackupFileSubtitle;

  /// No description provided for @exportFormattedList.
  ///
  /// In en, this message translates to:
  /// **'Formatted list'**
  String get exportFormattedList;

  /// No description provided for @exportFormattedListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'With checkboxes — great for notes apps'**
  String get exportFormattedListSubtitle;

  /// No description provided for @exportPlainText.
  ///
  /// In en, this message translates to:
  /// **'Plain text'**
  String get exportPlainText;

  /// No description provided for @exportPlainTextSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Simple list — paste anywhere'**
  String get exportPlainTextSubtitle;

  /// No description provided for @importFromBackupFile.
  ///
  /// In en, this message translates to:
  /// **'From backup file'**
  String get importFromBackupFile;

  /// No description provided for @importFromBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import a Recipe Spellbook backup'**
  String get importFromBackupSubtitle;

  /// No description provided for @importFromTextShoppingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Paste or type a list of items'**
  String get importFromTextShoppingSubtitle;

  /// No description provided for @importFromPhotoOcrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'OCR scan a handwritten or printed list'**
  String get importFromPhotoOcrSubtitle;

  /// No description provided for @importFromPhotoGallerySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a photo or pick from gallery'**
  String get importFromPhotoGallerySubtitle;

  /// No description provided for @shoppingSendToStore.
  ///
  /// In en, this message translates to:
  /// **'Send to store'**
  String get shoppingSendToStore;

  /// No description provided for @shoppingSendToCart.
  ///
  /// In en, this message translates to:
  /// **'Send to cart'**
  String get shoppingSendToCart;

  /// No description provided for @shoppingCopyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy list to clipboard'**
  String get shoppingCopyToClipboard;

  /// No description provided for @shoppingGoToCart.
  ///
  /// In en, this message translates to:
  /// **'Go to cart'**
  String get shoppingGoToCart;

  /// No description provided for @shoppingAddItems.
  ///
  /// In en, this message translates to:
  /// **'Add items'**
  String get shoppingAddItems;

  /// No description provided for @shoppingAddItemHintLong.
  ///
  /// In en, this message translates to:
  /// **'e.g. 2 cups flour, chicken breast...'**
  String get shoppingAddItemHintLong;

  /// No description provided for @importReviewItems.
  ///
  /// In en, this message translates to:
  /// **'Review items'**
  String get importReviewItems;

  /// No description provided for @importNoItemsDetected.
  ///
  /// In en, this message translates to:
  /// **'No items detected'**
  String get importNoItemsDetected;

  /// No description provided for @mealPlanDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get mealPlanDate;

  /// No description provided for @mealPlanThisWeekend.
  ///
  /// In en, this message translates to:
  /// **'This Weekend'**
  String get mealPlanThisWeekend;

  /// No description provided for @menuKitchenBuddy.
  ///
  /// In en, this message translates to:
  /// **'Kitchen Buddy'**
  String get menuKitchenBuddy;

  /// No description provided for @menuTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get menuTools;

  /// No description provided for @menuSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get menuSupport;

  /// No description provided for @menuHowCanWeHelp.
  ///
  /// In en, this message translates to:
  /// **'How can we help?'**
  String get menuHowCanWeHelp;

  /// No description provided for @menuGetInTouch.
  ///
  /// In en, this message translates to:
  /// **'Get in touch or browse our guides.'**
  String get menuGetInTouch;

  /// No description provided for @menuVisitWebsite.
  ///
  /// In en, this message translates to:
  /// **'Visit our Website'**
  String get menuVisitWebsite;

  /// No description provided for @feedbackTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get feedbackTitleLabel;

  /// No description provided for @feedbackDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get feedbackDetailsLabel;

  /// No description provided for @feedbackDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get feedbackDescriptionLabel;

  /// No description provided for @menuSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get menuSigningIn;

  /// No description provided for @menuSignInSync.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync & back up'**
  String get menuSignInSync;

  /// No description provided for @tagsSave.
  ///
  /// In en, this message translates to:
  /// **'Save Tags'**
  String get tagsSave;

  /// No description provided for @recipeFieldCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get recipeFieldCategories;

  /// No description provided for @selectCategories.
  ///
  /// In en, this message translates to:
  /// **'Select categories'**
  String get selectCategories;

  /// No description provided for @searchOrCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Search or create new...'**
  String get searchOrCreateNew;

  /// No description provided for @noMatchesFound.
  ///
  /// In en, this message translates to:
  /// **'No matches found'**
  String get noMatchesFound;

  /// No description provided for @taxonomyAddCategoryNew.
  ///
  /// In en, this message translates to:
  /// **'Add as new category'**
  String get taxonomyAddCategoryNew;

  /// No description provided for @ingredientSubstitutionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ingredient Substitutions'**
  String get ingredientSubstitutionsTitle;

  /// No description provided for @ingredientSubstitutionsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search for an ingredient...'**
  String get ingredientSubstitutionsSearch;

  /// No description provided for @ingredientSubstitutionsSearchAll.
  ///
  /// In en, this message translates to:
  /// **'Search all substitutions'**
  String get ingredientSubstitutionsSearchAll;

  /// No description provided for @ingredientName.
  ///
  /// In en, this message translates to:
  /// **'Ingredient Name'**
  String get ingredientName;

  /// No description provided for @ingredientNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. turmeric, tahini, miso'**
  String get ingredientNameHint;

  /// No description provided for @ingredientBulkHint.
  ///
  /// In en, this message translates to:
  /// **'Enter one ingredient per line:\n\n2 cups flour\n1 tsp salt\n3 eggs'**
  String get ingredientBulkHint;

  /// No description provided for @viewPlans.
  ///
  /// In en, this message translates to:
  /// **'View Plans'**
  String get viewPlans;

  /// No description provided for @renewsLabel.
  ///
  /// In en, this message translates to:
  /// **'Renews'**
  String get renewsLabel;

  /// No description provided for @upgradeToProUnlock.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro to unlock'**
  String get upgradeToProUnlock;

  /// No description provided for @kitchenBuddyTitle.
  ///
  /// In en, this message translates to:
  /// **'Kitchen Buddy'**
  String get kitchenBuddyTitle;

  /// No description provided for @kitchenBuddyCloset.
  ///
  /// In en, this message translates to:
  /// **'Closet'**
  String get kitchenBuddyCloset;

  /// No description provided for @kitchenBuddyShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get kitchenBuddyShop;

  /// No description provided for @kitchenBuddyAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get kitchenBuddyAchievements;

  /// No description provided for @kitchenBuddyStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String kitchenBuddyStreakDays(int count);

  /// No description provided for @kitchenBuddyClosetEmpty.
  ///
  /// In en, this message translates to:
  /// **'No items yet! Visit the Shop to get started.'**
  String get kitchenBuddyClosetEmpty;

  /// No description provided for @kitchenBuddyShopOwnEverything.
  ///
  /// In en, this message translates to:
  /// **'You own everything!'**
  String get kitchenBuddyShopOwnEverything;

  /// No description provided for @kitchenBuddyShopCheckBack.
  ///
  /// In en, this message translates to:
  /// **'Check back when new items are added.'**
  String get kitchenBuddyShopCheckBack;

  /// No description provided for @kitchenBuddyConfirmPurchase.
  ///
  /// In en, this message translates to:
  /// **'Buy {itemName}?'**
  String kitchenBuddyConfirmPurchase(String itemName);

  /// No description provided for @kitchenBuddyCostSummary.
  ///
  /// In en, this message translates to:
  /// **'This will cost 🪙 {price} Spice Coins.'**
  String kitchenBuddyCostSummary(int price);

  /// No description provided for @kitchenBuddyBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get kitchenBuddyBuy;

  /// No description provided for @kitchenBuddyPurchaseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchased {itemName}!'**
  String kitchenBuddyPurchaseSuccess(String itemName);

  /// No description provided for @kitchenBuddyNotEnoughCoins.
  ///
  /// In en, this message translates to:
  /// **'Not enough coins'**
  String get kitchenBuddyNotEnoughCoins;

  /// No description provided for @kitchenBuddyRequires.
  ///
  /// In en, this message translates to:
  /// **'Requires: {achievementName}'**
  String kitchenBuddyRequires(String achievementName);

  /// No description provided for @kitchenBuddyNamingTitle.
  ///
  /// In en, this message translates to:
  /// **'Name Your Buddy'**
  String get kitchenBuddyNamingTitle;

  /// No description provided for @kitchenBuddyIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Meet your Kitchen Buddy!'**
  String get kitchenBuddyIntroTitle;

  /// No description provided for @kitchenBuddyIntroDescription.
  ///
  /// In en, this message translates to:
  /// **'This little chef will be your kitchen companion.\nCook recipes and earn coins to dress them up!'**
  String get kitchenBuddyIntroDescription;

  /// No description provided for @kitchenBuddyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Buddy Name'**
  String get kitchenBuddyNameLabel;

  /// No description provided for @kitchenBuddyNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a name...'**
  String get kitchenBuddyNameHint;

  /// No description provided for @kitchenBuddyCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Buddy'**
  String get kitchenBuddyCreate;

  /// No description provided for @settingsNoMatchingSettings.
  ///
  /// In en, this message translates to:
  /// **'No matching settings'**
  String get settingsNoMatchingSettings;

  /// No description provided for @settingsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search settings...'**
  String get settingsSearchHint;

  /// No description provided for @textSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get textSizeSmall;

  /// No description provided for @textSizeDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get textSizeDefault;

  /// No description provided for @textSizeMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get textSizeMedium;

  /// No description provided for @textSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get textSizeLarge;

  /// No description provided for @textSizeExtraLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra Large'**
  String get textSizeExtraLarge;

  /// No description provided for @resetDataClearedDesc.
  ///
  /// In en, this message translates to:
  /// **'All data has been cleared successfully.\n\nWould you like to import the 10 default starter recipes?'**
  String get resetDataClearedDesc;

  /// No description provided for @yesImport.
  ///
  /// In en, this message translates to:
  /// **'Yes, Import'**
  String get yesImport;

  /// No description provided for @importingDefaultRecipes.
  ///
  /// In en, this message translates to:
  /// **'Importing default recipes...'**
  String get importingDefaultRecipes;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get checking;

  /// No description provided for @connectedTapToManage.
  ///
  /// In en, this message translates to:
  /// **'Connected • Tap to manage'**
  String get connectedTapToManage;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// No description provided for @tapToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Tap to sign in'**
  String get tapToSignIn;

  /// No description provided for @noneSelected.
  ///
  /// In en, this message translates to:
  /// **'None Selected'**
  String get noneSelected;

  /// No description provided for @partialBackup.
  ///
  /// In en, this message translates to:
  /// **'Partial Backup'**
  String get partialBackup;

  /// No description provided for @settingsShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping & Planning'**
  String get settingsShopping;

  /// No description provided for @settingsManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get settingsManage;

  /// No description provided for @manageTags.
  ///
  /// In en, this message translates to:
  /// **'Manage Tags'**
  String get manageTags;

  /// No description provided for @tagsApplied.
  ///
  /// In en, this message translates to:
  /// **'{count} tags applied'**
  String tagsApplied(int count);

  /// No description provided for @tagsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit \"{name}\"'**
  String tagsEditTitle(String name);

  /// No description provided for @tagsEditComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Tag editing coming soon!'**
  String get tagsEditComingSoon;

  /// No description provided for @tagsRecipeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} recipes'**
  String tagsRecipeCount(int count);

  /// No description provided for @communityMyPublications.
  ///
  /// In en, this message translates to:
  /// **'My Publications'**
  String get communityMyPublications;

  /// No description provided for @communitySearchCookbooks.
  ///
  /// In en, this message translates to:
  /// **'Search cookbooks...'**
  String get communitySearchCookbooks;

  /// No description provided for @communitySortRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get communitySortRecent;

  /// No description provided for @communitySortPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get communitySortPopular;

  /// No description provided for @communitySortMostDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Most Downloaded'**
  String get communitySortMostDownloaded;

  /// No description provided for @communityNoResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String communityNoResultsFor(String query);

  /// No description provided for @communityNoCookbooksYet.
  ///
  /// In en, this message translates to:
  /// **'No cookbooks yet'**
  String get communityNoCookbooksYet;

  /// No description provided for @communityClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get communityClearSearch;

  /// No description provided for @communityPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get communityPublish;

  /// No description provided for @communityByPublisher.
  ///
  /// In en, this message translates to:
  /// **'by {name}'**
  String communityByPublisher(String name);

  /// No description provided for @communityRecipeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} recipes'**
  String communityRecipeCount(int count);

  /// No description provided for @communityPublishCookbook.
  ///
  /// In en, this message translates to:
  /// **'Publish Cookbook'**
  String get communityPublishCookbook;

  /// No description provided for @communitySignInToPublish.
  ///
  /// In en, this message translates to:
  /// **'Sign in to publish'**
  String get communitySignInToPublish;

  /// No description provided for @communitySignInToPublishMessage.
  ///
  /// In en, this message translates to:
  /// **'You need an account to share cookbooks with the community.'**
  String get communitySignInToPublishMessage;

  /// No description provided for @communityGoToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get communityGoToSettings;

  /// No description provided for @communityNoCookbooksToPublish.
  ///
  /// In en, this message translates to:
  /// **'No cookbooks to publish'**
  String get communityNoCookbooksToPublish;

  /// No description provided for @communityPublishInfo.
  ///
  /// In en, this message translates to:
  /// **'Cookbooks need at least 10 recipes to publish. Your recipes will be shared as a snapshot — updates won\'t sync.'**
  String get communityPublishInfo;

  /// No description provided for @communitySelectCookbook.
  ///
  /// In en, this message translates to:
  /// **'Select a cookbook to publish'**
  String get communitySelectCookbook;

  /// No description provided for @communityNeedMinRecipes.
  ///
  /// In en, this message translates to:
  /// **'Need at least 10 recipes to publish (has {count})'**
  String communityNeedMinRecipes(int count);

  /// No description provided for @communityPublishConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Publish to Community?'**
  String get communityPublishConfirmTitle;

  /// No description provided for @communityPublishConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will share \"{name}\" ({count} recipes) publicly. Anyone can browse and download it.\n\nYou can unpublish it anytime.'**
  String communityPublishConfirmMessage(String name, int count);

  /// No description provided for @communityPublishSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" published to the community!'**
  String communityPublishSuccess(String name);

  /// No description provided for @communityPublishFailed.
  ///
  /// In en, this message translates to:
  /// **'Publish failed'**
  String get communityPublishFailed;

  /// No description provided for @communityRecipeCountNeedMore.
  ///
  /// In en, this message translates to:
  /// **'{count} recipes (need 10+)'**
  String communityRecipeCountNeedMore(int count);

  /// No description provided for @communityNoPublicationsYet.
  ///
  /// In en, this message translates to:
  /// **'No publications yet'**
  String get communityNoPublicationsYet;

  /// No description provided for @communityNoPublicationsMessage.
  ///
  /// In en, this message translates to:
  /// **'Publish a cookbook to share it with the community.'**
  String get communityNoPublicationsMessage;

  /// No description provided for @communityUnpublish.
  ///
  /// In en, this message translates to:
  /// **'Unpublish'**
  String get communityUnpublish;

  /// No description provided for @communityUnpublishConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Unpublish?'**
  String get communityUnpublishConfirmTitle;

  /// No description provided for @communityUnpublishConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{title}\" from the community? People who already downloaded it will keep their copy.'**
  String communityUnpublishConfirmMessage(String title);

  /// No description provided for @communityUnpublishSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" unpublished'**
  String communityUnpublishSuccess(String title);

  /// No description provided for @communityUnpublishFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to unpublish'**
  String get communityUnpublishFailed;

  /// No description provided for @communityRemovedByModeration.
  ///
  /// In en, this message translates to:
  /// **'Removed by moderation'**
  String get communityRemovedByModeration;

  /// No description provided for @communityPublicationStats.
  ///
  /// In en, this message translates to:
  /// **'{recipeCount} recipes · {downloadCount} downloads · {timeAgo}'**
  String communityPublicationStats(int recipeCount, int downloadCount, String timeAgo);

  /// No description provided for @communityPublicationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Publication not found'**
  String get communityPublicationNotFound;

  /// No description provided for @communityReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get communityReport;

  /// No description provided for @communityReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report this cookbook'**
  String get communityReportTitle;

  /// No description provided for @communityReportSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam or low quality'**
  String get communityReportSpam;

  /// No description provided for @communityReportInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get communityReportInappropriate;

  /// No description provided for @communityReportStolen.
  ///
  /// In en, this message translates to:
  /// **'Stolen / copied recipes'**
  String get communityReportStolen;

  /// No description provided for @communityReportOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get communityReportOther;

  /// No description provided for @communityReportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report submitted. Thank you!'**
  String get communityReportSuccess;

  /// No description provided for @communitySignInToReport.
  ///
  /// In en, this message translates to:
  /// **'Sign in to report content'**
  String get communitySignInToReport;

  /// No description provided for @communityDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get communityDownloadFailed;

  /// No description provided for @communityDownloadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Downloaded \"{title}\" — {count} recipes added!'**
  String communityDownloadSuccess(String title, int count);

  /// No description provided for @communityDownloadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Download failed: {error}'**
  String communityDownloadFailedError(String error);

  /// No description provided for @communityDownloadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} downloads'**
  String communityDownloadCount(int count);

  /// No description provided for @communityDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get communityDownloading;

  /// No description provided for @communityDownloadToMyCookbooks.
  ///
  /// In en, this message translates to:
  /// **'Download to My Cookbooks'**
  String get communityDownloadToMyCookbooks;

  /// No description provided for @communityPrepTime.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m prep'**
  String communityPrepTime(int minutes);

  /// No description provided for @communityCookTime.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m cook'**
  String communityCookTime(int minutes);

  /// No description provided for @communityServingsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} servings'**
  String communityServingsCount(int count);

  /// No description provided for @communityIngredientCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ingredients'**
  String communityIngredientCount(int count);

  /// No description provided for @deleteRecipesTrashMessage.
  ///
  /// In en, this message translates to:
  /// **'Recipes will be moved to trash. You can restore them later.'**
  String get deleteRecipesTrashMessage;

  /// No description provided for @hintTitleExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., Grandma\'s Apple Pie'**
  String get hintTitleExample;

  /// No description provided for @hintDescription.
  ///
  /// In en, this message translates to:
  /// **'A brief description of the recipe'**
  String get hintDescription;

  /// No description provided for @hintServingsExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., 4'**
  String get hintServingsExample;

  /// No description provided for @prepMin.
  ///
  /// In en, this message translates to:
  /// **'Prep (min)'**
  String get prepMin;

  /// No description provided for @cookMin.
  ///
  /// In en, this message translates to:
  /// **'Cook (min)'**
  String get cookMin;

  /// No description provided for @hintNotes.
  ///
  /// In en, this message translates to:
  /// **'Tips, variations, storage instructions...'**
  String get hintNotes;

  /// No description provided for @pinchToZoomCropped.
  ///
  /// In en, this message translates to:
  /// **'Pinch to zoom · Cropped area will be saved'**
  String get pinchToZoomCropped;

  /// No description provided for @pinchToZoomOrUseAsIs.
  ///
  /// In en, this message translates to:
  /// **'Pinch to zoom and crop · Or use as-is'**
  String get pinchToZoomOrUseAsIs;

  /// No description provided for @savingLabel.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get savingLabel;

  /// No description provided for @emptyHeader.
  ///
  /// In en, this message translates to:
  /// **'(empty header)'**
  String get emptyHeader;

  /// No description provided for @emptyIngredient.
  ///
  /// In en, this message translates to:
  /// **'(empty ingredient)'**
  String get emptyIngredient;

  /// No description provided for @recipeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Recipe updated!'**
  String get recipeUpdated;

  /// No description provided for @nutritionLessInfo.
  ///
  /// In en, this message translates to:
  /// **'Less info'**
  String get nutritionLessInfo;

  /// No description provided for @nutritionMoreInfo.
  ///
  /// In en, this message translates to:
  /// **'More info'**
  String get nutritionMoreInfo;

  /// No description provided for @scaleOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original: {servings}'**
  String scaleOriginal(String servings);

  /// No description provided for @scaleAdjustQuantities.
  ///
  /// In en, this message translates to:
  /// **'Adjust ingredient quantities'**
  String get scaleAdjustQuantities;

  /// No description provided for @scaleOriginalLabel.
  ///
  /// In en, this message translates to:
  /// **'1x (Original)'**
  String get scaleOriginalLabel;

  /// No description provided for @stepWillBeRemoved.
  ///
  /// In en, this message translates to:
  /// **'This step will be permanently removed.'**
  String get stepWillBeRemoved;

  /// No description provided for @stepsWillBeRemoved.
  ///
  /// In en, this message translates to:
  /// **'These {count} steps will be permanently removed.'**
  String stepsWillBeRemoved(int count);

  /// No description provided for @stepCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}}'**
  String stepCount(int count);

  /// No description provided for @instructionsNoSteps.
  ///
  /// In en, this message translates to:
  /// **'No instructions yet'**
  String get instructionsNoSteps;

  /// No description provided for @instructionsAddStepsGuide.
  ///
  /// In en, this message translates to:
  /// **'Add steps to guide through the recipe'**
  String get instructionsAddStepsGuide;

  /// No description provided for @pinchToZoomPreview.
  ///
  /// In en, this message translates to:
  /// **'Pinch to zoom · This is how your photo will look'**
  String get pinchToZoomPreview;

  /// No description provided for @ingredientCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 ingredient} other{{count} ingredients}}'**
  String ingredientCount(int count);

  /// No description provided for @ingredientPerLineHint.
  ///
  /// In en, this message translates to:
  /// **'Enter one ingredient per line:\n\n2 cups flour\n1 tsp salt\n3 eggs'**
  String get ingredientPerLineHint;

  /// No description provided for @ingredientTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Enter one ingredient per line. Press Enter after each ingredient.'**
  String get ingredientTip;

  /// No description provided for @cookbookEditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rename, cover photo'**
  String get cookbookEditSubtitle;

  /// No description provided for @shareCookbookSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Link, family, or community'**
  String get shareCookbookSubtitle;

  /// No description provided for @shareNamedCookbook.
  ///
  /// In en, this message translates to:
  /// **'Share \"{name}\"'**
  String shareNamedCookbook(String name);

  /// No description provided for @shareNamedList.
  ///
  /// In en, this message translates to:
  /// **'Share \"{name}\"'**
  String shareNamedList(String name);

  /// No description provided for @shareAsTextDescription.
  ///
  /// In en, this message translates to:
  /// **'Send list items as plain text'**
  String get shareAsTextDescription;

  /// No description provided for @oneTimeLink.
  ///
  /// In en, this message translates to:
  /// **'One-Time Link'**
  String get oneTimeLink;

  /// No description provided for @oneTimeLinkDescription.
  ///
  /// In en, this message translates to:
  /// **'Free • 24h expiry • Anyone can download'**
  String get oneTimeLinkDescription;

  /// No description provided for @familyShare.
  ///
  /// In en, this message translates to:
  /// **'Family Share'**
  String get familyShare;

  /// No description provided for @familyShareDescription.
  ///
  /// In en, this message translates to:
  /// **'Real-time sync with family members'**
  String get familyShareDescription;

  /// No description provided for @postToCommunity.
  ///
  /// In en, this message translates to:
  /// **'Post to Community'**
  String get postToCommunity;

  /// No description provided for @postToCommunityDescription.
  ///
  /// In en, this message translates to:
  /// **'Publish for anyone to discover & download'**
  String get postToCommunityDescription;

  /// No description provided for @signInToShare.
  ///
  /// In en, this message translates to:
  /// **'Sign in to create share links'**
  String get signInToShare;

  /// No description provided for @generatingLink.
  ///
  /// In en, this message translates to:
  /// **'Generating link...'**
  String get generatingLink;

  /// No description provided for @failedToCreateLink.
  ///
  /// In en, this message translates to:
  /// **'Failed to create link'**
  String get failedToCreateLink;

  /// No description provided for @linkCreated.
  ///
  /// In en, this message translates to:
  /// **'Link Created!'**
  String get linkCreated;

  /// No description provided for @expiresIn24Hours.
  ///
  /// In en, this message translates to:
  /// **'Expires in 24 hours'**
  String get expiresIn24Hours;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied!'**
  String get linkCopied;

  /// No description provided for @unlockFeature.
  ///
  /// In en, this message translates to:
  /// **'Unlock {feature}'**
  String unlockFeature(String feature);

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @upgradeButton.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgradeButton;

  /// No description provided for @publishMinRecipes.
  ///
  /// In en, this message translates to:
  /// **'Need at least 10 recipes to publish (has {count})'**
  String publishMinRecipes(int count);

  /// No description provided for @publishConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Post to Community?'**
  String get publishConfirmTitle;

  /// No description provided for @publishConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" ({count} recipes) will be publicly visible. Anyone can browse and download it.\n\nYou can remove it anytime from Community → My Publications.'**
  String publishConfirmMessage(String name, int count);

  /// No description provided for @publishButton.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publishButton;

  /// No description provided for @selectCourse.
  ///
  /// In en, this message translates to:
  /// **'Select Course'**
  String get selectCourse;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @taxonomyNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get taxonomyNone;

  /// No description provided for @createTaxonomy.
  ///
  /// In en, this message translates to:
  /// **'Create \"{name}\"'**
  String createTaxonomy(String name);

  /// No description provided for @addAsNewCourse.
  ///
  /// In en, this message translates to:
  /// **'Add as new course'**
  String get addAsNewCourse;

  /// No description provided for @addAsNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Add as new category'**
  String get addAsNewCategory;

  /// No description provided for @doneWithCount.
  ///
  /// In en, this message translates to:
  /// **'Done ({count})'**
  String doneWithCount(int count);

  /// No description provided for @quickAccessEmptyAll.
  ///
  /// In en, this message translates to:
  /// **'No quick access recipes yet'**
  String get quickAccessEmptyAll;

  /// No description provided for @quickAccessEmptyMealPlan.
  ///
  /// In en, this message translates to:
  /// **'No meals planned'**
  String get quickAccessEmptyMealPlan;

  /// No description provided for @quickAccessEmptyPinned.
  ///
  /// In en, this message translates to:
  /// **'No pinned recipes'**
  String get quickAccessEmptyPinned;

  /// No description provided for @quickAccessEmptyRecent.
  ///
  /// In en, this message translates to:
  /// **'No recent recipes'**
  String get quickAccessEmptyRecent;

  /// No description provided for @importingRecipe.
  ///
  /// In en, this message translates to:
  /// **'Importing recipe…'**
  String get importingRecipe;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @minutesPrepSuffix.
  ///
  /// In en, this message translates to:
  /// **'m prep'**
  String get minutesPrepSuffix;

  /// No description provided for @minutesCookSuffix.
  ///
  /// In en, this message translates to:
  /// **'m cook'**
  String get minutesCookSuffix;

  /// No description provided for @couldNotOpenBrowser.
  ///
  /// In en, this message translates to:
  /// **'Could not open browser'**
  String get couldNotOpenBrowser;

  /// No description provided for @couldNotOpenUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not open {url}'**
  String couldNotOpenUrl(String url);

  /// No description provided for @discord.
  ///
  /// In en, this message translates to:
  /// **'Discord'**
  String get discord;

  /// No description provided for @discordLinkAccount.
  ///
  /// In en, this message translates to:
  /// **'Link Discord Account'**
  String get discordLinkAccount;

  /// No description provided for @discordLinkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect your Discord for community features'**
  String get discordLinkSubtitle;

  /// No description provided for @discordSignInFirst.
  ///
  /// In en, this message translates to:
  /// **'Sign in first to link Discord'**
  String get discordSignInFirst;

  /// No description provided for @discordUnlink.
  ///
  /// In en, this message translates to:
  /// **'Unlink Discord'**
  String get discordUnlink;

  /// No description provided for @discordUnlinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to unlink Discord'**
  String get discordUnlinkFailed;

  /// No description provided for @discordUnlinkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove your Discord connection'**
  String get discordUnlinkSubtitle;

  /// No description provided for @discordUnlinked.
  ///
  /// In en, this message translates to:
  /// **'Discord unlinked'**
  String get discordUnlinked;

  /// No description provided for @familyCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite code copied!'**
  String get familyCodeCopied;

  /// No description provided for @familyCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get familyCopyLink;

  /// No description provided for @familyCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Family'**
  String get familyCreate;

  /// No description provided for @familyCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create family'**
  String get familyCreateFailed;

  /// No description provided for @familyCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Family'**
  String get familyCreateTitle;

  /// No description provided for @familyCreated.
  ///
  /// In en, this message translates to:
  /// **'Family created!'**
  String get familyCreated;

  /// No description provided for @familyDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Family'**
  String get familyDelete;

  /// No description provided for @familyDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this family? All members will be removed.'**
  String get familyDeleteConfirm;

  /// No description provided for @familyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Family deleted'**
  String get familyDeleted;

  /// No description provided for @familyEnterInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Enter invite code'**
  String get familyEnterInviteCode;

  /// No description provided for @familyInvite.
  ///
  /// In en, this message translates to:
  /// **'Invite Members'**
  String get familyInvite;

  /// No description provided for @familyJoinAction.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get familyJoinAction;

  /// No description provided for @familyJoinFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to join family'**
  String get familyJoinFailed;

  /// No description provided for @familyJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join Family'**
  String get familyJoinTitle;

  /// No description provided for @familyJoinWithCode.
  ///
  /// In en, this message translates to:
  /// **'Join with Code'**
  String get familyJoinWithCode;

  /// No description provided for @familyJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined {familyName}!'**
  String familyJoined(String familyName);

  /// No description provided for @familyLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave Family'**
  String get familyLeave;

  /// No description provided for @familyLeaveAction.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get familyLeaveAction;

  /// No description provided for @familyLeaveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave this family?'**
  String get familyLeaveConfirm;

  /// No description provided for @familyLeft.
  ///
  /// In en, this message translates to:
  /// **'Left family'**
  String get familyLeft;

  /// No description provided for @familyLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite link copied!'**
  String get familyLinkCopied;

  /// No description provided for @familyManage.
  ///
  /// In en, this message translates to:
  /// **'Manage your family'**
  String get familyManage;

  /// No description provided for @familyMemberRemoved.
  ///
  /// In en, this message translates to:
  /// **'{displayName} removed'**
  String familyMemberRemoved(String displayName);

  /// No description provided for @familyMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get familyMembers;

  /// No description provided for @familyMembersCount.
  ///
  /// In en, this message translates to:
  /// **'{current} of {max} members'**
  String familyMembersCount(int current, int max);

  /// No description provided for @familyNameHint.
  ///
  /// In en, this message translates to:
  /// **'Family name'**
  String get familyNameHint;

  /// No description provided for @familyNewCodeGenerated.
  ///
  /// In en, this message translates to:
  /// **'New invite code generated'**
  String get familyNewCodeGenerated;

  /// No description provided for @familyOwner.
  ///
  /// In en, this message translates to:
  /// **'OWNER'**
  String get familyOwner;

  /// No description provided for @familyRegenerateCode.
  ///
  /// In en, this message translates to:
  /// **'Regenerate Code'**
  String get familyRegenerateCode;

  /// No description provided for @familyRemoveMember.
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get familyRemoveMember;

  /// No description provided for @familyRemoveMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {displayName} from the family?'**
  String familyRemoveMemberConfirm(String displayName);

  /// No description provided for @familyRename.
  ///
  /// In en, this message translates to:
  /// **'Rename Family'**
  String get familyRename;

  /// No description provided for @familyShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Join my family on Recipe Spellbook! Code: {inviteCode} or use this link: {shareLink}'**
  String familyShareMessage(String inviteCode, String shareLink);

  /// No description provided for @familyShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Join my Recipe Spellbook family'**
  String get familyShareSubject;

  /// No description provided for @familyShareUpgradeMessage.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to share cookbooks with family members in real-time.'**
  String get familyShareUpgradeMessage;

  /// No description provided for @familySharing.
  ///
  /// In en, this message translates to:
  /// **'Family Sharing'**
  String get familySharing;

  /// No description provided for @familySharingDescription.
  ///
  /// In en, this message translates to:
  /// **'Share cookbooks, shopping lists, and meal plans with your family.'**
  String get familySharingDescription;

  /// No description provided for @familySharingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share cookbooks, lists & meal plans'**
  String get familySharingSubtitle;

  /// No description provided for @ingredientSubstitutesFor.
  ///
  /// In en, this message translates to:
  /// **'Substitutes for {ingredientName}'**
  String ingredientSubstitutesFor(String ingredientName);

  /// No description provided for @ingredientSubstitutionsNoResults.
  ///
  /// In en, this message translates to:
  /// **'No substitutions found'**
  String get ingredientSubstitutionsNoResults;

  /// No description provided for @ingredientSubstitutionsNotFound.
  ///
  /// In en, this message translates to:
  /// **'No substitutions found for {ingredientName}'**
  String ingredientSubstitutionsNotFound(String ingredientName);

  /// No description provided for @ingredientSubstitutionsTryDifferent.
  ///
  /// In en, this message translates to:
  /// **'Try a different ingredient'**
  String get ingredientSubstitutionsTryDifferent;

  /// No description provided for @integrationsChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get integrationsChecking;

  /// No description provided for @integrationsConnectedManage.
  ///
  /// In en, this message translates to:
  /// **'Connected - Tap to manage'**
  String get integrationsConnectedManage;

  /// No description provided for @integrationsLinked.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get integrationsLinked;

  /// No description provided for @integrationsLinkedManage.
  ///
  /// In en, this message translates to:
  /// **'Linked - Tap to manage'**
  String get integrationsLinkedManage;

  /// No description provided for @integrationsNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get integrationsNotConnected;

  /// No description provided for @integrationsTapToLink.
  ///
  /// In en, this message translates to:
  /// **'Tap to link'**
  String get integrationsTapToLink;

  /// No description provided for @integrationsTapToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Tap to sign in'**
  String get integrationsTapToSignIn;

  /// No description provided for @nutritionCalculateFromEdit.
  ///
  /// In en, this message translates to:
  /// **'Calculate from the edit screen'**
  String get nutritionCalculateFromEdit;

  /// No description provided for @nutritionCaloriesAlwaysShow.
  ///
  /// In en, this message translates to:
  /// **'Always show calories'**
  String get nutritionCaloriesAlwaysShow;

  /// No description provided for @nutritionChartStyle.
  ///
  /// In en, this message translates to:
  /// **'Chart Style'**
  String get nutritionChartStyle;

  /// No description provided for @nutritionResetDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get nutritionResetDefaults;

  /// No description provided for @nutritionSettingsLink.
  ///
  /// In en, this message translates to:
  /// **'Nutrition settings'**
  String get nutritionSettingsLink;

  /// No description provided for @nutritionTapToCalculate.
  ///
  /// In en, this message translates to:
  /// **'Tap to calculate nutrition'**
  String get nutritionTapToCalculate;

  /// No description provided for @nutritionVisibleNutrients.
  ///
  /// In en, this message translates to:
  /// **'Visible Nutrients'**
  String get nutritionVisibleNutrients;

  /// No description provided for @pantryAddedStaples.
  ///
  /// In en, this message translates to:
  /// **'Added {count} staples to pantry'**
  String pantryAddedStaples(int count);

  /// No description provided for @pantryClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get pantryClearAll;

  /// No description provided for @pantryClearMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove all items from your pantry?'**
  String get pantryClearMessage;

  /// No description provided for @pantryCommonStaples.
  ///
  /// In en, this message translates to:
  /// **'Common Staples'**
  String get pantryCommonStaples;

  /// No description provided for @pantryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your pantry is empty'**
  String get pantryEmpty;

  /// No description provided for @pantryEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add items you always have on hand'**
  String get pantryEmptySubtitle;

  /// No description provided for @pantryInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'Items in your pantry will be excluded from shopping lists when adding recipe ingredients.'**
  String get pantryInfoMessage;

  /// No description provided for @pantryItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String pantryItemCount(int count);

  /// No description provided for @mealPlanAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to Meal Plan'**
  String get mealPlanAddTitle;

  /// No description provided for @mealPlanMealLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get mealPlanMealLabel;

  /// No description provided for @mealPlanAdding.
  ///
  /// In en, this message translates to:
  /// **'Adding...'**
  String get mealPlanAdding;

  /// No description provided for @mealPlanDateFormat.
  ///
  /// In en, this message translates to:
  /// **'{weekday}, {month} {day}'**
  String mealPlanDateFormat(String weekday, String month, int day);

  /// No description provided for @splashRecipe.
  ///
  /// In en, this message translates to:
  /// **'Recipe'**
  String get splashRecipe;

  /// No description provided for @splashSpellbook.
  ///
  /// In en, this message translates to:
  /// **'Spellbook'**
  String get splashSpellbook;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Your culinary adventure awaits'**
  String get splashTagline;

  /// No description provided for @smartImportReparsed.
  ///
  /// In en, this message translates to:
  /// **'Re-parsed by AI — review the updated recipe above'**
  String get smartImportReparsed;

  /// No description provided for @servingSizeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 1 cup, 100g'**
  String get servingSizeHint;

  /// No description provided for @mainNutrients.
  ///
  /// In en, this message translates to:
  /// **'Main Nutrients'**
  String get mainNutrients;

  /// No description provided for @additionalNutrients.
  ///
  /// In en, this message translates to:
  /// **'Additional Nutrients'**
  String get additionalNutrients;

  /// No description provided for @onboardingWelcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get onboardingWelcomeTo;

  /// No description provided for @onboardingAppName.
  ///
  /// In en, this message translates to:
  /// **'Recipe Spellbook!'**
  String get onboardingAppName;

  /// No description provided for @onboardingDescription.
  ///
  /// In en, this message translates to:
  /// **'10 handpicked recipes from around the world to get you started.'**
  String get onboardingDescription;

  /// No description provided for @onboardingDeleteLater.
  ///
  /// In en, this message translates to:
  /// **'You can always delete them later.'**
  String get onboardingDeleteLater;

  /// No description provided for @onboardingAdding.
  ///
  /// In en, this message translates to:
  /// **'Adding...'**
  String get onboardingAdding;

  /// No description provided for @onboardingAddStarter.
  ///
  /// In en, this message translates to:
  /// **'Add starter recipes'**
  String get onboardingAddStarter;

  /// No description provided for @onboardingBlankCookbook.
  ///
  /// In en, this message translates to:
  /// **'Start with a blank cookbook'**
  String get onboardingBlankCookbook;

  /// No description provided for @onboardingBlankConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with nothing?'**
  String get onboardingBlankConfirmTitle;

  /// No description provided for @onboardingBlankConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You can always add the starter recipes later from Settings.'**
  String get onboardingBlankConfirmBody;

  /// No description provided for @onboardingBlankConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, start empty'**
  String get onboardingBlankConfirmYes;

  /// No description provided for @onboardingSpellbookAwaits.
  ///
  /// In en, this message translates to:
  /// **'Your Spellbook Awaits'**
  String get onboardingSpellbookAwaits;

  /// No description provided for @onboardingYourSpellbookAwaits.
  ///
  /// In en, this message translates to:
  /// **'Your spellbook awaits...'**
  String get onboardingYourSpellbookAwaits;

  /// No description provided for @onboardingSummoning.
  ///
  /// In en, this message translates to:
  /// **'Summoning...'**
  String get onboardingSummoning;

  /// No description provided for @onboardingBlankSpellbook.
  ///
  /// In en, this message translates to:
  /// **'Start with a blank spellbook'**
  String get onboardingBlankSpellbook;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @settingsBrowseCommunity.
  ///
  /// In en, this message translates to:
  /// **'Browse Community'**
  String get settingsBrowseCommunity;

  /// No description provided for @settingsBrowseCommunitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover public cookbooks'**
  String get settingsBrowseCommunitySubtitle;

  /// No description provided for @settingsCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get settingsCommunity;

  /// No description provided for @settingsFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get settingsFamily;

  /// No description provided for @settingsIntegrations.
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get settingsIntegrations;

  /// No description provided for @settingsMyPublications.
  ///
  /// In en, this message translates to:
  /// **'My Publications'**
  String get settingsMyPublications;

  /// No description provided for @settingsMyPublicationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your published cookbooks'**
  String get settingsMyPublicationsSubtitle;

  /// No description provided for @settingsShoppingPlanning.
  ///
  /// In en, this message translates to:
  /// **'Shopping & Planning'**
  String get settingsShoppingPlanning;

  /// No description provided for @shoppingAddCountItems.
  ///
  /// In en, this message translates to:
  /// **'Add {count} items'**
  String shoppingAddCountItems(int count);

  /// No description provided for @shoppingAddIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get shoppingAddIngredient;

  /// No description provided for @shoppingAddedItemName.
  ///
  /// In en, this message translates to:
  /// **'Added \"{name}\"'**
  String shoppingAddedItemName(String name);

  /// No description provided for @shoppingAddedNotFound.
  ///
  /// In en, this message translates to:
  /// **'{added} added, {failed} not found'**
  String shoppingAddedNotFound(int added, int failed);

  /// No description provided for @shoppingAddingTo.
  ///
  /// In en, this message translates to:
  /// **'Adding to {provider}…'**
  String shoppingAddingTo(String provider);

  /// No description provided for @shoppingCamera.
  ///
  /// In en, this message translates to:
  /// **'camera'**
  String get shoppingCamera;

  /// No description provided for @shoppingCheckedItemsCount.
  ///
  /// In en, this message translates to:
  /// **'Checked items ({count})'**
  String shoppingCheckedItemsCount(int count);

  /// No description provided for @shoppingCouldNotAccessSource.
  ///
  /// In en, this message translates to:
  /// **'Could not access {source}'**
  String shoppingCouldNotAccessSource(String source);

  /// No description provided for @shoppingCountAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} added'**
  String shoppingCountAdded(int count);

  /// No description provided for @shoppingCreatingListOn.
  ///
  /// In en, this message translates to:
  /// **'Creating list on {provider}…'**
  String shoppingCreatingListOn(String provider);

  /// No description provided for @shoppingCurrentOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total} items'**
  String shoppingCurrentOfTotal(int current, int total);

  /// No description provided for @shoppingDeleteListConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String shoppingDeleteListConfirm(String name);

  /// No description provided for @shoppingErrorReadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error reading image: {error}'**
  String shoppingErrorReadingImage(String error);

  /// No description provided for @shoppingExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String shoppingExportFailed(String error);

  /// No description provided for @shoppingExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export \"{name}\"'**
  String shoppingExportTitle(String name);

  /// No description provided for @shoppingFamilyShare.
  ///
  /// In en, this message translates to:
  /// **'Family Share'**
  String get shoppingFamilyShare;

  /// No description provided for @shoppingFamilyShareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share list with family or one-time link'**
  String get shoppingFamilyShareSubtitle;

  /// No description provided for @shoppingFromPhoto.
  ///
  /// In en, this message translates to:
  /// **'From photo'**
  String get shoppingFromPhoto;

  /// No description provided for @shoppingFromText.
  ///
  /// In en, this message translates to:
  /// **'From text'**
  String get shoppingFromText;

  /// No description provided for @shoppingGallery.
  ///
  /// In en, this message translates to:
  /// **'gallery'**
  String get shoppingGallery;

  /// No description provided for @shoppingImportItems.
  ///
  /// In en, this message translates to:
  /// **'Import items'**
  String get shoppingImportItems;

  /// No description provided for @shoppingImportShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Import shopping list'**
  String get shoppingImportShoppingList;

  /// No description provided for @shoppingImportTextHint.
  ///
  /// In en, this message translates to:
  /// **'2 cups flour\nchicken breast\n1 lb ground beef\nmilk\n...'**
  String get shoppingImportTextHint;

  /// No description provided for @shoppingImportedList.
  ///
  /// In en, this message translates to:
  /// **'Imported List'**
  String get shoppingImportedList;

  /// No description provided for @shoppingIngredientHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., chicken breast, olive oil'**
  String get shoppingIngredientHint;

  /// No description provided for @shoppingIngredientName.
  ///
  /// In en, this message translates to:
  /// **'Ingredient Name'**
  String get shoppingIngredientName;

  /// No description provided for @shoppingIngredientsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} ingredients available'**
  String shoppingIngredientsAvailable(int count);

  /// No description provided for @shoppingItemsAddedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items added'**
  String shoppingItemsAddedCount(int count);

  /// No description provided for @shoppingItemsAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Items added!'**
  String get shoppingItemsAddedSuccess;

  /// No description provided for @shoppingItemsCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'{count} items copied to clipboard'**
  String shoppingItemsCopiedToClipboard(int count);

  /// No description provided for @shoppingItemsInCart.
  ///
  /// In en, this message translates to:
  /// **'{count} items in your {provider} cart'**
  String shoppingItemsInCart(int count, String provider);

  /// No description provided for @shoppingItemsOnInstacartList.
  ///
  /// In en, this message translates to:
  /// **'{count} items on your Instacart list'**
  String shoppingItemsOnInstacartList(int count);

  /// No description provided for @shoppingJustAdded.
  ///
  /// In en, this message translates to:
  /// **'Just added'**
  String get shoppingJustAdded;

  /// No description provided for @shoppingListCopiedOpening.
  ///
  /// In en, this message translates to:
  /// **'List copied! Opening {name}...'**
  String shoppingListCopiedOpening(String name);

  /// No description provided for @shoppingListReady.
  ///
  /// In en, this message translates to:
  /// **'Shopping list ready!'**
  String get shoppingListReady;

  /// No description provided for @shoppingNotFoundItems.
  ///
  /// In en, this message translates to:
  /// **'Not found: {items}'**
  String shoppingNotFoundItems(String items);

  /// No description provided for @shoppingOneItemPerLine.
  ///
  /// In en, this message translates to:
  /// **'One item per line'**
  String get shoppingOneItemPerLine;

  /// No description provided for @shoppingPartiallyAdded.
  ///
  /// In en, this message translates to:
  /// **'Partially added'**
  String get shoppingPartiallyAdded;

  /// No description provided for @shoppingProviderConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get shoppingProviderConnected;

  /// No description provided for @shoppingRemoveFromList.
  ///
  /// In en, this message translates to:
  /// **'Remove from list'**
  String get shoppingRemoveFromList;

  /// No description provided for @shoppingStartTyping.
  ///
  /// In en, this message translates to:
  /// **'Start typing to see suggestions'**
  String get shoppingStartTyping;

  /// No description provided for @shoppingTapToAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Tap to add items directly to your cart'**
  String get shoppingTapToAddToCart;

  /// No description provided for @shoppingTapToCreateShoppableList.
  ///
  /// In en, this message translates to:
  /// **'Tap to create a shoppable list'**
  String get shoppingTapToCreateShoppableList;

  /// No description provided for @swipeToSwitch.
  ///
  /// In en, this message translates to:
  /// **'Swipe to switch sections'**
  String get swipeToSwitch;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @syncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Synced: {pushed} pushed, {pulled} pulled'**
  String syncSuccess(int pushed, int pulled);

  /// No description provided for @textSizePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get textSizePreview;

  /// No description provided for @transferDeviceDesktop.
  ///
  /// In en, this message translates to:
  /// **'desktop'**
  String get transferDeviceDesktop;

  /// No description provided for @transferDeviceMobileApp.
  ///
  /// In en, this message translates to:
  /// **'mobile app'**
  String get transferDeviceMobileApp;

  /// No description provided for @transferDeviceThisDevice.
  ///
  /// In en, this message translates to:
  /// **'this device'**
  String get transferDeviceThisDevice;

  /// No description provided for @transferExplanation.
  ///
  /// In en, this message translates to:
  /// **'Move all your recipes, cookbooks, and meal plans from {currentDevice} to your {targetDevice}. This is a one-time copy, not a sync.'**
  String transferExplanation(String currentDevice, String targetDevice);

  /// No description provided for @transferImportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count} items imported successfully.'**
  String transferImportedSuccess(int count);

  /// No description provided for @transferOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get transferOr;

  /// No description provided for @transferReceiveOn.
  ///
  /// In en, this message translates to:
  /// **'Receive on {device}'**
  String transferReceiveOn(String device);

  /// No description provided for @transferSendFrom.
  ///
  /// In en, this message translates to:
  /// **'Send from {device}'**
  String transferSendFrom(String device);

  /// No description provided for @transferSendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate a code for your {device} to receive'**
  String transferSendSubtitle(String device);

  /// No description provided for @importGuidesTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Guides'**
  String get importGuidesTitle;

  /// No description provided for @importGuidesOpenInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open guides in browser'**
  String get importGuidesOpenInBrowser;

  /// No description provided for @importGuideHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Bring your recipes from anywhere'**
  String get importGuideHeroTitle;

  /// No description provided for @importGuideHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap any guide below for step-by-step instructions with screenshots.'**
  String get importGuideHeroSubtitle;

  /// No description provided for @importGuideQuickTipLabel.
  ///
  /// In en, this message translates to:
  /// **'Quick tip'**
  String get importGuideQuickTipLabel;

  /// No description provided for @importGuideQuickTipText.
  ///
  /// In en, this message translates to:
  /// **'The fastest way? Copy any recipe link and share it to Recipe Spellbook — works from almost any app.'**
  String get importGuideQuickTipText;

  /// No description provided for @importGuideWebButton.
  ///
  /// In en, this message translates to:
  /// **'Web'**
  String get importGuideWebButton;

  /// No description provided for @importGuideFollowInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Follow along in browser'**
  String get importGuideFollowInBrowser;

  /// No description provided for @importGuideTagPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get importGuideTagPopular;

  /// No description provided for @importGuideTagEasiest.
  ///
  /// In en, this message translates to:
  /// **'Easiest'**
  String get importGuideTagEasiest;

  /// No description provided for @importGuideDifficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get importGuideDifficultyEasy;

  /// No description provided for @importGuideDifficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get importGuideDifficultyMedium;

  /// No description provided for @importGuideTime15Sec.
  ///
  /// In en, this message translates to:
  /// **'15 sec'**
  String get importGuideTime15Sec;

  /// No description provided for @importGuideTime30Sec.
  ///
  /// In en, this message translates to:
  /// **'30 sec'**
  String get importGuideTime30Sec;

  /// No description provided for @importGuideTime1Min.
  ///
  /// In en, this message translates to:
  /// **'1 min'**
  String get importGuideTime1Min;

  /// No description provided for @importGuideTime2To5Min.
  ///
  /// In en, this message translates to:
  /// **'2–5 min'**
  String get importGuideTime2To5Min;

  /// No description provided for @importGuideStepsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} steps'**
  String importGuideStepsCount(int count);

  /// No description provided for @importGuideCategorySocial.
  ///
  /// In en, this message translates to:
  /// **'Social Media'**
  String get importGuideCategorySocial;

  /// No description provided for @importGuideCategoryWebsites.
  ///
  /// In en, this message translates to:
  /// **'Websites'**
  String get importGuideCategoryWebsites;

  /// No description provided for @importGuideCategoryPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos & Files'**
  String get importGuideCategoryPhotos;

  /// No description provided for @importGuideCategoryOtherApps.
  ///
  /// In en, this message translates to:
  /// **'Other Recipe Apps'**
  String get importGuideCategoryOtherApps;

  /// No description provided for @importGuideCategoryAi.
  ///
  /// In en, this message translates to:
  /// **'AI Import'**
  String get importGuideCategoryAi;

  /// No description provided for @importGuideTagNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get importGuideTagNew;

  /// No description provided for @importGuideScreenshotNeeded.
  ///
  /// In en, this message translates to:
  /// **'Screenshot needed'**
  String get importGuideScreenshotNeeded;

  /// No description provided for @importGuideGifNeeded.
  ///
  /// In en, this message translates to:
  /// **'GIF needed'**
  String get importGuideGifNeeded;

  /// No description provided for @importGuideVideoNeeded.
  ///
  /// In en, this message translates to:
  /// **'Video needed'**
  String get importGuideVideoNeeded;

  /// No description provided for @importGuideInstagramTitle.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get importGuideInstagramTitle;

  /// No description provided for @importGuideInstagramSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import from Reels, posts, and stories'**
  String get importGuideInstagramSubtitle;

  /// No description provided for @importGuideInstagramStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Find a recipe post or Reel'**
  String get importGuideInstagramStep1Title;

  /// No description provided for @importGuideInstagramStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Open Instagram and find a recipe you want to save. This works with feed posts, Reels, and carousels.'**
  String get importGuideInstagramStep1Desc;

  /// No description provided for @importGuideInstagramStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Tap the share button'**
  String get importGuideInstagramStep2Title;

  /// No description provided for @importGuideInstagramStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap the paper plane icon (share) below the post.'**
  String get importGuideInstagramStep2Desc;

  /// No description provided for @importGuideInstagramStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Share to Recipe Spellbook'**
  String get importGuideInstagramStep3Title;

  /// No description provided for @importGuideInstagramStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Scroll the app row and tap Recipe Spellbook. If you don\'t see it, tap \"More\" and find it in the list.'**
  String get importGuideInstagramStep3Desc;

  /// No description provided for @importGuideInstagramStep3Tip.
  ///
  /// In en, this message translates to:
  /// **'On Android, you can also copy the link and paste it in the app.'**
  String get importGuideInstagramStep3Tip;

  /// No description provided for @importGuideInstagramStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Find Recipe Spellbook'**
  String get importGuideInstagramStep4Title;

  /// No description provided for @importGuideInstagramStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap More to see all your apps, then find and tap Recipe Spellbook.'**
  String get importGuideInstagramStep4Desc;

  /// No description provided for @importGuideInstagramStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Preview & import'**
  String get importGuideInstagramStep5Title;

  /// No description provided for @importGuideInstagramStep5Desc.
  ///
  /// In en, this message translates to:
  /// **'Review the recipe details and tap Import to save it to your cookbook.'**
  String get importGuideInstagramStep5Desc;

  /// No description provided for @importGuideTiktokTitle.
  ///
  /// In en, this message translates to:
  /// **'TikTok'**
  String get importGuideTiktokTitle;

  /// No description provided for @importGuideTiktokSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save recipes from cooking videos'**
  String get importGuideTiktokSubtitle;

  /// No description provided for @importGuideTiktokStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Find a recipe TikTok'**
  String get importGuideTiktokStep1Title;

  /// No description provided for @importGuideTiktokStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Open TikTok and find a cooking video you want to save.'**
  String get importGuideTiktokStep1Desc;

  /// No description provided for @importGuideTiktokStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Tap the share arrow'**
  String get importGuideTiktokStep2Title;

  /// No description provided for @importGuideTiktokStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap the arrow icon on the right side of the video.'**
  String get importGuideTiktokStep2Desc;

  /// No description provided for @importGuideTiktokStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Choose \"Copy link\" or share directly'**
  String get importGuideTiktokStep3Title;

  /// No description provided for @importGuideTiktokStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Either tap \"Copy link\" and paste in Recipe Spellbook, or find Recipe Spellbook in the share options.'**
  String get importGuideTiktokStep3Desc;

  /// No description provided for @importGuideTiktokStep3Tip.
  ///
  /// In en, this message translates to:
  /// **'\"Copy link\" is often the most reliable method for TikTok.'**
  String get importGuideTiktokStep3Tip;

  /// No description provided for @importGuideTiktokStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Find Recipe Spellbook'**
  String get importGuideTiktokStep4Title;

  /// No description provided for @importGuideTiktokStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap More to see all your apps, then find and tap Recipe Spellbook.'**
  String get importGuideTiktokStep4Desc;

  /// No description provided for @importGuideTiktokStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Preview & import'**
  String get importGuideTiktokStep5Title;

  /// No description provided for @importGuideTiktokStep5Desc.
  ///
  /// In en, this message translates to:
  /// **'Review the recipe details and tap Import to save it to your cookbook.'**
  String get importGuideTiktokStep5Desc;

  /// No description provided for @importGuideYoutubeTitle.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get importGuideYoutubeTitle;

  /// No description provided for @importGuideYoutubeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import from cooking channels & Shorts'**
  String get importGuideYoutubeSubtitle;

  /// No description provided for @importGuideYoutubeStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Find a recipe video'**
  String get importGuideYoutubeStep1Title;

  /// No description provided for @importGuideYoutubeStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Open YouTube and find a cooking video. Works with regular videos, Shorts, and livestream replays.'**
  String get importGuideYoutubeStep1Desc;

  /// No description provided for @importGuideYoutubeStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Tap Share'**
  String get importGuideYoutubeStep2Title;

  /// No description provided for @importGuideYoutubeStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap the Share button below the video title.'**
  String get importGuideYoutubeStep2Desc;

  /// No description provided for @importGuideYoutubeStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Copy link or share to app'**
  String get importGuideYoutubeStep3Title;

  /// No description provided for @importGuideYoutubeStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Copy link\" or find Recipe Spellbook in the share sheet.'**
  String get importGuideYoutubeStep3Desc;

  /// No description provided for @importGuideYoutubeStep3Tip.
  ///
  /// In en, this message translates to:
  /// **'Many YouTube creators put the full recipe in the video description — this makes extraction more accurate.'**
  String get importGuideYoutubeStep3Tip;

  /// No description provided for @importGuideYoutubeStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Preview & import'**
  String get importGuideYoutubeStep4Title;

  /// No description provided for @importGuideYoutubeStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'Review the extracted recipe and tap Import to save it to your cookbook.'**
  String get importGuideYoutubeStep4Desc;

  /// No description provided for @importGuidePinterestTitle.
  ///
  /// In en, this message translates to:
  /// **'Pinterest'**
  String get importGuidePinterestTitle;

  /// No description provided for @importGuidePinterestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save pinned recipes to your cookbook'**
  String get importGuidePinterestSubtitle;

  /// No description provided for @importGuidePinterestStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Open a recipe pin'**
  String get importGuidePinterestStep1Title;

  /// No description provided for @importGuidePinterestStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap a recipe pin to open it. Most pins link to the original recipe website.'**
  String get importGuidePinterestStep1Desc;

  /// No description provided for @importGuidePinterestStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Tap the source link'**
  String get importGuidePinterestStep2Title;

  /// No description provided for @importGuidePinterestStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap the link at the top or bottom of the pin to visit the original recipe page.'**
  String get importGuidePinterestStep2Desc;

  /// No description provided for @importGuidePinterestStep2Tip.
  ///
  /// In en, this message translates to:
  /// **'If the pin doesn\'t have a source link, try the share method below instead.'**
  String get importGuidePinterestStep2Tip;

  /// No description provided for @importGuidePinterestStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Share to Recipe Spellbook'**
  String get importGuidePinterestStep3Title;

  /// No description provided for @importGuidePinterestStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap the share button and select Recipe Spellbook from the app list.'**
  String get importGuidePinterestStep3Desc;

  /// No description provided for @importGuidePinterestStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Preview & import'**
  String get importGuidePinterestStep4Title;

  /// No description provided for @importGuidePinterestStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'Review the recipe details and tap Import to save it to your cookbook.'**
  String get importGuidePinterestStep4Desc;

  /// No description provided for @importGuideWebsiteTitle.
  ///
  /// In en, this message translates to:
  /// **'Any Recipe Website'**
  String get importGuideWebsiteTitle;

  /// No description provided for @importGuideWebsiteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AllRecipes, Food Network, BBC, blogs & more'**
  String get importGuideWebsiteSubtitle;

  /// No description provided for @importGuideWebsiteStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Open the recipe page'**
  String get importGuideWebsiteStep1Title;

  /// No description provided for @importGuideWebsiteStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Navigate to any recipe on sites like AllRecipes, Food Network, BBC Good Food, Serious Eats, NYT Cooking, or any food blog.'**
  String get importGuideWebsiteStep1Desc;

  /// No description provided for @importGuideWebsiteStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Copy the URL'**
  String get importGuideWebsiteStep2Title;

  /// No description provided for @importGuideWebsiteStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap the address bar and copy the full URL to the recipe.'**
  String get importGuideWebsiteStep2Desc;

  /// No description provided for @importGuideWebsiteStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Tap the Share button'**
  String get importGuideWebsiteStep3Title;

  /// No description provided for @importGuideWebsiteStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap the browser\'s share or More button to see sharing options.'**
  String get importGuideWebsiteStep3Desc;

  /// No description provided for @importGuideWebsiteStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Choose Recipe Spellbook'**
  String get importGuideWebsiteStep4Title;

  /// No description provided for @importGuideWebsiteStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'Find and tap Recipe Spellbook in the app list.'**
  String get importGuideWebsiteStep4Desc;

  /// No description provided for @importGuideWebsiteStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Preview & import'**
  String get importGuideWebsiteStep5Title;

  /// No description provided for @importGuideWebsiteStep5Desc.
  ///
  /// In en, this message translates to:
  /// **'Review the extracted recipe and tap Import to save it to your cookbook.'**
  String get importGuideWebsiteStep5Desc;

  /// No description provided for @importGuideWebsiteStep5Tip.
  ///
  /// In en, this message translates to:
  /// **'Works with 10,000+ recipe sites. If extraction fails, try the \"From Text\" method.'**
  String get importGuideWebsiteStep5Tip;

  /// No description provided for @importGuidePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo / Camera'**
  String get importGuidePhotoTitle;

  /// No description provided for @importGuidePhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan recipes from books, magazines, or handwritten cards'**
  String get importGuidePhotoSubtitle;

  /// No description provided for @importGuidePhotoStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Photograph the recipe'**
  String get importGuidePhotoStep1Title;

  /// No description provided for @importGuidePhotoStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Take a clear, well-lit photo of a recipe from a cookbook, magazine page, or handwritten recipe card. Make sure all text is readable.'**
  String get importGuidePhotoStep1Desc;

  /// No description provided for @importGuidePhotoStep1Tip.
  ///
  /// In en, this message translates to:
  /// **'For best results: use good lighting, hold steady, and make sure the entire recipe is in frame. Avoid shadows.'**
  String get importGuidePhotoStep1Tip;

  /// No description provided for @importGuidePhotoStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Tap + then \"From Photo\"'**
  String get importGuidePhotoStep2Title;

  /// No description provided for @importGuidePhotoStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Open Recipe Spellbook, tap +, and choose \"From Photo\". Select the photo from your gallery or take a new one.'**
  String get importGuidePhotoStep2Desc;

  /// No description provided for @importGuidePhotoStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Select your image'**
  String get importGuidePhotoStep3Title;

  /// No description provided for @importGuidePhotoStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Pick the recipe image from your gallery.'**
  String get importGuidePhotoStep3Desc;

  /// No description provided for @importGuidePhotoStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Review & fix any errors'**
  String get importGuidePhotoStep4Title;

  /// No description provided for @importGuidePhotoStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'Check the extracted recipe. OCR occasionally misreads characters — \"1/2\" might become \"1l2\". Fix any errors and save.'**
  String get importGuidePhotoStep4Desc;

  /// No description provided for @importGuidePhotoStep4Tip.
  ///
  /// In en, this message translates to:
  /// **'Handwritten recipes work too, but printed text gives the best results.'**
  String get importGuidePhotoStep4Tip;

  /// No description provided for @importGuidePdfTitle.
  ///
  /// In en, this message translates to:
  /// **'PDF Document'**
  String get importGuidePdfTitle;

  /// No description provided for @importGuidePdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import from PDF cookbooks or downloads'**
  String get importGuidePdfSubtitle;

  /// No description provided for @importGuidePdfStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Have a recipe PDF ready'**
  String get importGuidePdfStep1Title;

  /// No description provided for @importGuidePdfStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'This works with downloaded recipe PDFs, ebook cookbooks, scanned documents, or PDFs shared via email.'**
  String get importGuidePdfStep1Desc;

  /// No description provided for @importGuidePdfStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Tap + then \"From PDF\"'**
  String get importGuidePdfStep2Title;

  /// No description provided for @importGuidePdfStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Open Recipe Spellbook, tap +, choose \"From PDF\", and select your file.'**
  String get importGuidePdfStep2Desc;

  /// No description provided for @importGuidePdfStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Select the recipe page'**
  String get importGuidePdfStep3Title;

  /// No description provided for @importGuidePdfStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'If the PDF has multiple pages, choose which page contains the recipe you want to import.'**
  String get importGuidePdfStep3Desc;

  /// No description provided for @importGuidePdfStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Review & save'**
  String get importGuidePdfStep4Title;

  /// No description provided for @importGuidePdfStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'The recipe is extracted from the PDF. Review the ingredients and steps, then save to your cookbook.'**
  String get importGuidePdfStep4Desc;

  /// No description provided for @importGuideTextTitle.
  ///
  /// In en, this message translates to:
  /// **'Text / Paste'**
  String get importGuideTextTitle;

  /// No description provided for @importGuideTextSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Paste a recipe from messages, email, or notes'**
  String get importGuideTextSubtitle;

  /// No description provided for @importGuideTextStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Copy recipe text'**
  String get importGuideTextStep1Title;

  /// No description provided for @importGuideTextStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Copy the recipe text from a text message, email, notes app, WhatsApp, or anywhere else.'**
  String get importGuideTextStep1Desc;

  /// No description provided for @importGuideTextStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Tap + then \"From Text\"'**
  String get importGuideTextStep2Title;

  /// No description provided for @importGuideTextStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Open Recipe Spellbook, tap +, and choose \"From Text\".'**
  String get importGuideTextStep2Desc;

  /// No description provided for @importGuideTextStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Paste your recipe'**
  String get importGuideTextStep3Title;

  /// No description provided for @importGuideTextStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Paste the copied text into the text field. The AI will automatically separate the title, ingredients, and steps.'**
  String get importGuideTextStep3Desc;

  /// No description provided for @importGuideTextStep3Tip.
  ///
  /// In en, this message translates to:
  /// **'This works even with unformatted text — the AI is smart about parsing ingredient amounts and step instructions.'**
  String get importGuideTextStep3Tip;

  /// No description provided for @importGuideTextStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Review & save'**
  String get importGuideTextStep4Title;

  /// No description provided for @importGuideTextStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'Check the parsed recipe, make any adjustments, and save.'**
  String get importGuideTextStep4Desc;

  /// No description provided for @importGuideAiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI (ChatGPT, Claude, etc.)'**
  String get importGuideAiTitle;

  /// No description provided for @importGuideAiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate recipes with AI and import them instantly'**
  String get importGuideAiSubtitle;

  /// No description provided for @importGuideAiStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Open AI Import'**
  String get importGuideAiStep1Title;

  /// No description provided for @importGuideAiStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Go to Home, tap + to add a recipe, choose Import, then tap the AI button.'**
  String get importGuideAiStep1Desc;

  /// No description provided for @importGuideAiStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Copy the prompt'**
  String get importGuideAiStep2Title;

  /// No description provided for @importGuideAiStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap the copy prompt button. Then open your favorite AI — ChatGPT, Claude, Gemini, or any other — and paste the prompt.'**
  String get importGuideAiStep2Desc;

  /// No description provided for @importGuideAiStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Copy the AI\'s response'**
  String get importGuideAiStep3Title;

  /// No description provided for @importGuideAiStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'The AI will generate a recipe in JSON format. Copy the entire response.'**
  String get importGuideAiStep3Desc;

  /// No description provided for @importGuideAiStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Paste into Recipe Spellbook'**
  String get importGuideAiStep4Title;

  /// No description provided for @importGuideAiStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'Go back to Recipe Spellbook, tap the paste button, then tap Preview to see the parsed recipe.'**
  String get importGuideAiStep4Desc;

  /// No description provided for @importGuideAiStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Preview & import'**
  String get importGuideAiStep5Title;

  /// No description provided for @importGuideAiStep5Desc.
  ///
  /// In en, this message translates to:
  /// **'Check that everything looks correct, then tap Import to save the recipe to your cookbook.'**
  String get importGuideAiStep5Desc;

  /// No description provided for @importGuideOtherAppsTitle.
  ///
  /// In en, this message translates to:
  /// **'Other Recipe Apps'**
  String get importGuideOtherAppsTitle;

  /// No description provided for @importGuideOtherAppsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mealime, CopyMeThat, AnyList, Cookmate, etc.'**
  String get importGuideOtherAppsSubtitle;

  /// No description provided for @importGuideOtherAppsStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Export from your current app'**
  String get importGuideOtherAppsStep1Title;

  /// No description provided for @importGuideOtherAppsStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Most recipe apps support exporting to JSON, HTML, or text. Check their Settings > Export or Backup section.'**
  String get importGuideOtherAppsStep1Desc;

  /// No description provided for @importGuideOtherAppsStep1Tip.
  ///
  /// In en, this message translates to:
  /// **'Common formats: JSON (best), HTML, PDF, or plain text. JSON preserves the most data.'**
  String get importGuideOtherAppsStep1Tip;

  /// No description provided for @importGuideOtherAppsStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Get the file on your device'**
  String get importGuideOtherAppsStep2Title;

  /// No description provided for @importGuideOtherAppsStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Save or transfer the exported file to your phone using email, cloud storage, or a file transfer method.'**
  String get importGuideOtherAppsStep2Desc;

  /// No description provided for @importGuideOtherAppsStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Import the file'**
  String get importGuideOtherAppsStep3Title;

  /// No description provided for @importGuideOtherAppsStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'In Recipe Spellbook, open the main menu and tap Add Recipe → Import → File, then select the exported file. The app handles JSON, HTML, and common recipe formats.'**
  String get importGuideOtherAppsStep3Desc;

  /// No description provided for @importGuideOtherAppsStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Check your recipes'**
  String get importGuideOtherAppsStep4Title;

  /// No description provided for @importGuideOtherAppsStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'Imported recipes appear in your default cookbook. You can reorganize them into different cookbooks afterward.'**
  String get importGuideOtherAppsStep4Desc;

  /// No description provided for @importGuideDeviceTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Transfer'**
  String get importGuideDeviceTransferTitle;

  /// No description provided for @importGuideDeviceTransferSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Move recipes between phones without an account'**
  String get importGuideDeviceTransferSubtitle;

  /// No description provided for @importGuideDeviceTransferStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Open Transfer on the OLD device'**
  String get importGuideDeviceTransferStep1Title;

  /// No description provided for @importGuideDeviceTransferStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'On your old phone, open Recipe Spellbook and go to Menu > Device Transfer > Send.'**
  String get importGuideDeviceTransferStep1Desc;

  /// No description provided for @importGuideDeviceTransferStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Get the transfer code'**
  String get importGuideDeviceTransferStep2Title;

  /// No description provided for @importGuideDeviceTransferStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'A 6-character code is generated. This code is valid for 15 minutes.'**
  String get importGuideDeviceTransferStep2Desc;

  /// No description provided for @importGuideDeviceTransferStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Enter code on NEW device'**
  String get importGuideDeviceTransferStep3Title;

  /// No description provided for @importGuideDeviceTransferStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'On your new phone, install Recipe Spellbook and go to Menu > Device Transfer > Receive. Enter the code.'**
  String get importGuideDeviceTransferStep3Desc;

  /// No description provided for @importGuideDeviceTransferStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Recipes transferred!'**
  String get importGuideDeviceTransferStep4Title;

  /// No description provided for @importGuideDeviceTransferStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'All your recipes, cookbooks, shopping lists, and meal plans are transferred to the new device.'**
  String get importGuideDeviceTransferStep4Desc;

  /// No description provided for @importGuideDeviceTransferStep4Tip.
  ///
  /// In en, this message translates to:
  /// **'Have a paid account? Just sign in on the new device and everything syncs automatically.'**
  String get importGuideDeviceTransferStep4Tip;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get faqTitle;

  /// No description provided for @faqHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get faqHeroTitle;

  /// No description provided for @faqHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find answers and step-by-step guides for common features.'**
  String get faqHeroSubtitle;

  /// No description provided for @faqHowToGuides.
  ///
  /// In en, this message translates to:
  /// **'How-to Guides'**
  String get faqHowToGuides;

  /// No description provided for @faqCommonQuestions.
  ///
  /// In en, this message translates to:
  /// **'Common Questions'**
  String get faqCommonQuestions;

  /// No description provided for @faqSeeHowTo.
  ///
  /// In en, this message translates to:
  /// **'See how-to guide'**
  String get faqSeeHowTo;

  /// No description provided for @faqStepsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} steps'**
  String faqStepsCount(int count);

  /// No description provided for @faqAddHeadersTitle.
  ///
  /// In en, this message translates to:
  /// **'How to add headers'**
  String get faqAddHeadersTitle;

  /// No description provided for @faqAddHeadersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize your recipe ingredients and steps into sections'**
  String get faqAddHeadersSubtitle;

  /// No description provided for @faqAddHeadersStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Open the recipe editor'**
  String get faqAddHeadersStep1Title;

  /// No description provided for @faqAddHeadersStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Open a recipe and tap the edit icon.'**
  String get faqAddHeadersStep1Desc;

  /// No description provided for @faqAddHeadersStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Add a header'**
  String get faqAddHeadersStep2Title;

  /// No description provided for @faqAddHeadersStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap the \'Add Header\' button to insert a section header.'**
  String get faqAddHeadersStep2Desc;

  /// No description provided for @faqAddHeadersStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Open the header menu'**
  String get faqAddHeadersStep3Title;

  /// No description provided for @faqAddHeadersStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap the three dots (⋮) next to the header for more options.'**
  String get faqAddHeadersStep3Desc;

  /// No description provided for @faqAddHeadersStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Reorder your headers'**
  String get faqAddHeadersStep4Title;

  /// No description provided for @faqAddHeadersStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap Sort Order to rearrange. Drag the ≡ handle to move headers up or down.'**
  String get faqAddHeadersStep4Desc;

  /// No description provided for @faqAddHeadersStep4Tip.
  ///
  /// In en, this message translates to:
  /// **'You can drag headers by holding the ≡ (two lines) handle on the left side.'**
  String get faqAddHeadersStep4Tip;

  /// No description provided for @faqAddHeadersStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Save your changes'**
  String get faqAddHeadersStep5Title;

  /// No description provided for @faqAddHeadersStep5Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap the save button to keep your new headers.'**
  String get faqAddHeadersStep5Desc;

  /// No description provided for @faqAddHeadersStep6Title.
  ///
  /// In en, this message translates to:
  /// **'Done!'**
  String get faqAddHeadersStep6Title;

  /// No description provided for @faqAddHeadersStep6Desc.
  ///
  /// In en, this message translates to:
  /// **'Your recipe now has organized sections with headers.'**
  String get faqAddHeadersStep6Desc;

  /// No description provided for @faqAddSublinkedTitle.
  ///
  /// In en, this message translates to:
  /// **'How to add sublinked recipes'**
  String get faqAddSublinkedTitle;

  /// No description provided for @faqAddSublinkedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Link related recipes together for quick access'**
  String get faqAddSublinkedSubtitle;

  /// No description provided for @faqAddSublinkedStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Open the recipe editor'**
  String get faqAddSublinkedStep1Title;

  /// No description provided for @faqAddSublinkedStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Open a recipe and tap the edit icon.'**
  String get faqAddSublinkedStep1Desc;

  /// No description provided for @faqAddSublinkedStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Open the menu'**
  String get faqAddSublinkedStep2Title;

  /// No description provided for @faqAddSublinkedStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap the three dots (⋮) in the edit screen.'**
  String get faqAddSublinkedStep2Desc;

  /// No description provided for @faqAddSublinkedStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Tap Link Recipe'**
  String get faqAddSublinkedStep3Title;

  /// No description provided for @faqAddSublinkedStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Select \'Link Recipe\' from the menu.'**
  String get faqAddSublinkedStep3Desc;

  /// No description provided for @faqAddSublinkedStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Choose a recipe to link'**
  String get faqAddSublinkedStep4Title;

  /// No description provided for @faqAddSublinkedStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap the link icon next to the recipe you want to connect (e.g., Pizza Dough).'**
  String get faqAddSublinkedStep4Desc;

  /// No description provided for @faqAddSublinkedStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Save your changes'**
  String get faqAddSublinkedStep5Title;

  /// No description provided for @faqAddSublinkedStep5Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap the save icon to keep the linked recipe.'**
  String get faqAddSublinkedStep5Desc;

  /// No description provided for @faqAddSublinkedStep6Title.
  ///
  /// In en, this message translates to:
  /// **'Done!'**
  String get faqAddSublinkedStep6Title;

  /// No description provided for @faqAddSublinkedStep6Desc.
  ///
  /// In en, this message translates to:
  /// **'The linked recipe now appears in your recipe, ready to tap and view.'**
  String get faqAddSublinkedStep6Desc;

  /// No description provided for @faqWhatAreHeadersTitle.
  ///
  /// In en, this message translates to:
  /// **'What are headers?'**
  String get faqWhatAreHeadersTitle;

  /// No description provided for @faqWhatAreHeadersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize recipes into sections'**
  String get faqWhatAreHeadersSubtitle;

  /// No description provided for @faqWhatAreHeadersAnswer.
  ///
  /// In en, this message translates to:
  /// **'Headers let you divide your recipe ingredients and steps into sections. For example, you could have separate sections for \'Sauce\', \'Dough\', and \'Topping\' in a pizza recipe. They make long recipes much easier to follow.'**
  String get faqWhatAreHeadersAnswer;

  /// No description provided for @faqWhatAreSublinkedTitle.
  ///
  /// In en, this message translates to:
  /// **'What are sublinked recipes?'**
  String get faqWhatAreSublinkedTitle;

  /// No description provided for @faqWhatAreSublinkedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect related recipes together'**
  String get faqWhatAreSublinkedSubtitle;

  /// No description provided for @faqWhatAreSublinkedAnswer.
  ///
  /// In en, this message translates to:
  /// **'Sublinked recipes let you connect related recipes together. For example, a Margherita Pizza recipe can link to your Pizza Dough recipe. When viewing the main recipe, you can tap the linked recipe to jump straight to it — no searching needed.'**
  String get faqWhatAreSublinkedAnswer;

  /// No description provided for @faqMacroCalcTitle.
  ///
  /// In en, this message translates to:
  /// **'How to use the Macro Calculator'**
  String get faqMacroCalcTitle;

  /// No description provided for @faqMacroCalcSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-calculate calories and macros for any recipe'**
  String get faqMacroCalcSubtitle;

  /// No description provided for @faqMacroCalcStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Open a recipe'**
  String get faqMacroCalcStep1Title;

  /// No description provided for @faqMacroCalcStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Open any recipe to view its details.'**
  String get faqMacroCalcStep1Desc;

  /// No description provided for @faqMacroCalcStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Find the Nutrition section'**
  String get faqMacroCalcStep2Title;

  /// No description provided for @faqMacroCalcStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Scroll to the bottom of the recipe. If no nutrition data exists yet, you\'ll see an empty state — tap it to start the calculator.'**
  String get faqMacroCalcStep2Desc;

  /// No description provided for @faqMacroCalcStep3Title.
  ///
  /// In en, this message translates to:
  /// **'View the calculator'**
  String get faqMacroCalcStep3Title;

  /// No description provided for @faqMacroCalcStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'The calculator automatically matches your ingredients to the USDA food database and shows the match rate, calories, and macro breakdown.'**
  String get faqMacroCalcStep3Desc;

  /// No description provided for @faqMacroCalcStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get faqMacroCalcStep4Title;

  /// No description provided for @faqMacroCalcStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap \'Enter Manually\' to edit nutrition values by hand if you prefer to input your own data instead of using the auto-calculated results.'**
  String get faqMacroCalcStep4Desc;

  /// No description provided for @faqMacroCalcStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Review ingredient matches'**
  String get faqMacroCalcStep5Title;

  /// No description provided for @faqMacroCalcStep5Desc.
  ///
  /// In en, this message translates to:
  /// **'Scroll down to see each ingredient matched to a USDA food item. Sublinked recipes (like Pizza Dough) use their own stored nutrition instead.'**
  String get faqMacroCalcStep5Desc;

  /// No description provided for @faqMacroCalcStep5Tip.
  ///
  /// In en, this message translates to:
  /// **'Not sure what a sublinked recipe is? Check out the \'What are sublinked recipes?\' section in the FAQ!'**
  String get faqMacroCalcStep5Tip;

  /// No description provided for @faqMacroCalcStep6Title.
  ///
  /// In en, this message translates to:
  /// **'Browse the USDA database'**
  String get faqMacroCalcStep6Title;

  /// No description provided for @faqMacroCalcStep6Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap any ingredient to search the USDA database for a better match. You can pick from thousands of verified food items.'**
  String get faqMacroCalcStep6Desc;

  /// No description provided for @faqMacroCalcStep7Title.
  ///
  /// In en, this message translates to:
  /// **'Linked recipe nutrition'**
  String get faqMacroCalcStep7Title;

  /// No description provided for @faqMacroCalcStep7Desc.
  ///
  /// In en, this message translates to:
  /// **'Ingredients linked to other recipes show the linked recipe\'s nutrition data. You can adjust the scale to use a fraction of the linked recipe.'**
  String get faqMacroCalcStep7Desc;

  /// No description provided for @faqMacroCalcStep8Title.
  ///
  /// In en, this message translates to:
  /// **'Save your results'**
  String get faqMacroCalcStep8Title;

  /// No description provided for @faqMacroCalcStep8Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap Save to store the nutrition data. The macros will now appear on your recipe with charts and detailed breakdowns per serving.'**
  String get faqMacroCalcStep8Desc;

  /// No description provided for @faqMacroCalcStep9Title.
  ///
  /// In en, this message translates to:
  /// **'Customize the display'**
  String get faqMacroCalcStep9Title;

  /// No description provided for @faqMacroCalcStep9Desc.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings > Nutrition Display to choose which nutrients to show and how the charts are displayed.'**
  String get faqMacroCalcStep9Desc;

  /// No description provided for @faqWhatIsMacroCalcTitle.
  ///
  /// In en, this message translates to:
  /// **'What is the Macro Calculator?'**
  String get faqWhatIsMacroCalcTitle;

  /// No description provided for @faqWhatIsMacroCalcSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic nutrition estimation for recipes'**
  String get faqWhatIsMacroCalcSubtitle;

  /// No description provided for @faqWhatIsMacroCalcAnswer.
  ///
  /// In en, this message translates to:
  /// **'The Macro Calculator automatically estimates the nutritional content of your recipes by matching each ingredient to the USDA food database. It calculates calories, protein, carbs, fat, fiber, sugar, sodium, and more — all per serving. You can find it in the Nutrition section of any recipe.'**
  String get faqWhatIsMacroCalcAnswer;

  /// No description provided for @faqImportFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Why did my import fail?'**
  String get faqImportFailedTitle;

  /// No description provided for @faqImportFailedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Common reasons and fixes'**
  String get faqImportFailedSubtitle;

  /// No description provided for @faqImportFailedAnswer.
  ///
  /// In en, this message translates to:
  /// **'Imports can fail for a few reasons:\n\n• The website may block automated access — try copying the recipe text and using Text Import instead.\n• The link may have expired or be private — make sure it’s a public link.\n• Some sites use formats that are harder to parse — try the AI import as an alternative.\n• Check your internet connection and try again.'**
  String get faqImportFailedAnswer;

  /// No description provided for @faqDeviceTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Can I import from other devices?'**
  String get faqDeviceTransferTitle;

  /// No description provided for @faqDeviceTransferSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer recipes between phones and tablets'**
  String get faqDeviceTransferSubtitle;

  /// No description provided for @faqDeviceTransferAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes! Use the Device Transfer feature in Settings > Data > Device Transfer. Generate a code on your old device and enter it on your new one. All your recipes, cookbooks, and images will be transferred.'**
  String get faqDeviceTransferAnswer;

  /// No description provided for @themeFrost.
  ///
  /// In en, this message translates to:
  /// **'Frost'**
  String get themeFrost;

  /// No description provided for @themeEmber.
  ///
  /// In en, this message translates to:
  /// **'Ember'**
  String get themeEmber;

  /// No description provided for @themeSpring.
  ///
  /// In en, this message translates to:
  /// **'Spring'**
  String get themeSpring;

  /// No description provided for @themeAlchemist.
  ///
  /// In en, this message translates to:
  /// **'Alchemist'**
  String get themeAlchemist;

  /// No description provided for @themeMatcha.
  ///
  /// In en, this message translates to:
  /// **'Matcha'**
  String get themeMatcha;

  /// No description provided for @themeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get themeCustom;

  /// No description provided for @communitySortTopRated.
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get communitySortTopRated;

  /// No description provided for @communityHasImages.
  ///
  /// In en, this message translates to:
  /// **'Has Images'**
  String get communityHasImages;

  /// No description provided for @communityListView.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get communityListView;

  /// No description provided for @communityGridView.
  ///
  /// In en, this message translates to:
  /// **'Grid view'**
  String get communityGridView;

  /// No description provided for @communityDownloadOptions.
  ///
  /// In en, this message translates to:
  /// **'Download Options'**
  String get communityDownloadOptions;

  /// No description provided for @communityDownloadWithImages.
  ///
  /// In en, this message translates to:
  /// **'With images ({size})'**
  String communityDownloadWithImages(String size);

  /// No description provided for @communityDownloadImagesIncluded.
  ///
  /// In en, this message translates to:
  /// **'{count} images included'**
  String communityDownloadImagesIncluded(int count);

  /// No description provided for @communityDownloadTextOnly.
  ///
  /// In en, this message translates to:
  /// **'Text only'**
  String get communityDownloadTextOnly;

  /// No description provided for @communityDownloadTextOnlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Faster download, no images'**
  String get communityDownloadTextOnlySubtitle;

  /// No description provided for @communityTapToPreview.
  ///
  /// In en, this message translates to:
  /// **'Tap a recipe to preview'**
  String get communityTapToPreview;

  /// No description provided for @communityImageCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} images'**
  String communityImageCountLabel(int count);

  /// No description provided for @communityYourRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating:'**
  String get communityYourRating;

  /// No description provided for @communityRateThis.
  ///
  /// In en, this message translates to:
  /// **'Rate this cookbook:'**
  String get communityRateThis;

  /// No description provided for @communityDownloadingImages.
  ///
  /// In en, this message translates to:
  /// **'Downloading images... {current}/{total}'**
  String communityDownloadingImages(int current, int total);

  /// No description provided for @communityViewFullRecipe.
  ///
  /// In en, this message translates to:
  /// **'View Full Recipe'**
  String get communityViewFullRecipe;

  /// No description provided for @communityMoreIngredients.
  ///
  /// In en, this message translates to:
  /// **'+ {count} more'**
  String communityMoreIngredients(int count);

  /// No description provided for @communityStepCount.
  ///
  /// In en, this message translates to:
  /// **'{count} steps'**
  String communityStepCount(int count);

  /// No description provided for @communityNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get communityNotes;

  /// No description provided for @communityStatPrep.
  ///
  /// In en, this message translates to:
  /// **'Prep'**
  String get communityStatPrep;

  /// No description provided for @communityStatCook.
  ///
  /// In en, this message translates to:
  /// **'Cook'**
  String get communityStatCook;

  /// No description provided for @communityStatTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get communityStatTotal;

  /// No description provided for @communityStatServings.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get communityStatServings;

  /// No description provided for @communityStepDuration.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String communityStepDuration(int minutes);

  /// No description provided for @communityEditPublication.
  ///
  /// In en, this message translates to:
  /// **'Edit Publication'**
  String get communityEditPublication;

  /// No description provided for @communityEditDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get communityEditDescription;

  /// No description provided for @communityEditDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Tell people about this cookbook...'**
  String get communityEditDescriptionHint;

  /// No description provided for @communityEditTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get communityEditTags;

  /// No description provided for @communityEditSuccess.
  ///
  /// In en, this message translates to:
  /// **'Publication updated!'**
  String get communityEditSuccess;

  /// No description provided for @communityEditFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update publication'**
  String get communityEditFailed;

  /// No description provided for @communityNoRatingsYet.
  ///
  /// In en, this message translates to:
  /// **'No ratings yet'**
  String get communityNoRatingsYet;

  /// No description provided for @communityStatusPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get communityStatusPublished;

  /// No description provided for @communityStatusUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get communityStatusUnderReview;

  /// No description provided for @communityStatusRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get communityStatusRemoved;

  /// No description provided for @communityUnderReview.
  ///
  /// In en, this message translates to:
  /// **'This cookbook is under review by our moderation team.'**
  String get communityUnderReview;

  /// No description provided for @communityPublishPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing cookbook...'**
  String get communityPublishPreparing;

  /// No description provided for @communityPublishUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading images ({current}/{total})'**
  String communityPublishUploading(int current, int total);

  /// No description provided for @communityPublishPublishing.
  ///
  /// In en, this message translates to:
  /// **'Publishing to community...'**
  String get communityPublishPublishing;

  /// No description provided for @communityPublishBackground.
  ///
  /// In en, this message translates to:
  /// **'You can leave this screen — publishing continues in the background.'**
  String get communityPublishBackground;

  /// No description provided for @communityPublishDone.
  ///
  /// In en, this message translates to:
  /// **'Published!'**
  String get communityPublishDone;

  /// No description provided for @communityPublishImagesSkipped.
  ///
  /// In en, this message translates to:
  /// **'{count} images were skipped (rejected by moderation)'**
  String communityPublishImagesSkipped(int count);

  /// No description provided for @communityPublishRejected.
  ///
  /// In en, this message translates to:
  /// **'{count} rejected by moderation'**
  String communityPublishRejected(int count);

  /// No description provided for @communityConfigurePublication.
  ///
  /// In en, this message translates to:
  /// **'Configure Publication'**
  String get communityConfigurePublication;

  /// No description provided for @communityPublishTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get communityPublishTitle;

  /// No description provided for @communityPublishTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Cookbook title'**
  String get communityPublishTitleHint;

  /// No description provided for @communityPublishDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get communityPublishDescription;

  /// No description provided for @communityPublishDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Tell people about this cookbook...'**
  String get communityPublishDescriptionHint;

  /// No description provided for @communityPublishTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get communityPublishTags;

  /// No description provided for @communityPublishIncludeImages.
  ///
  /// In en, this message translates to:
  /// **'Include images'**
  String get communityPublishIncludeImages;

  /// No description provided for @communityPublishIncludeImagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload recipe images with this cookbook. Images are scanned for safety.'**
  String get communityPublishIncludeImagesSubtitle;

  /// No description provided for @communityPublishSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get communityPublishSummary;

  /// No description provided for @communityPublishRecipesSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} recipes'**
  String communityPublishRecipesSummary(int count);

  /// No description provided for @communityPublishImagesWillUpload.
  ///
  /// In en, this message translates to:
  /// **'Images will be uploaded'**
  String get communityPublishImagesWillUpload;

  /// No description provided for @communityPublishTextOnlyNoImages.
  ///
  /// In en, this message translates to:
  /// **'Text only (no images)'**
  String get communityPublishTextOnlyNoImages;

  /// No description provided for @communityPublishTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get communityPublishTryAgain;

  /// No description provided for @communityPublishUploadInProgress.
  ///
  /// In en, this message translates to:
  /// **'Publishing in progress... ({current}/{total} images)'**
  String communityPublishUploadInProgress(int current, int total);

  /// No description provided for @surpriseMeTitle.
  ///
  /// In en, this message translates to:
  /// **'Surprise Me!'**
  String get surpriseMeTitle;

  /// No description provided for @surpriseMeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What should I cook?'**
  String get surpriseMeSubtitle;

  /// No description provided for @hintNutritionCalculator.
  ///
  /// In en, this message translates to:
  /// **'Did you know? Tap the nutrition icon to auto-calculate nutrition for any recipe.'**
  String get hintNutritionCalculator;

  /// No description provided for @hintCookingScreen.
  ///
  /// In en, this message translates to:
  /// **'Try cooking mode! Tap \'Cook\' on any recipe for hands-free step-by-step instructions.'**
  String get hintCookingScreen;

  /// No description provided for @hintIngredientHeaders.
  ///
  /// In en, this message translates to:
  /// **'Tip: Type a line ending with \':\' in ingredients to create a section header.'**
  String get hintIngredientHeaders;

  /// No description provided for @hintImportMethods.
  ///
  /// In en, this message translates to:
  /// **'Import recipes from URLs, photos, PDFs, or even Instagram and TikTok!'**
  String get hintImportMethods;

  /// No description provided for @hintMealPlanAutoFill.
  ///
  /// In en, this message translates to:
  /// **'Drag recipes into your meal plan, or tap a day to pick from your collection.'**
  String get hintMealPlanAutoFill;

  /// No description provided for @hintRecipeScaling.
  ///
  /// In en, this message translates to:
  /// **'Tap the servings number on any recipe to scale ingredients up or down.'**
  String get hintRecipeScaling;

  /// No description provided for @hintShoppingListGen.
  ///
  /// In en, this message translates to:
  /// **'Add recipe ingredients to your shopping list with one tap.'**
  String get hintShoppingListGen;

  /// No description provided for @hintRecipeNotes.
  ///
  /// In en, this message translates to:
  /// **'Add personal notes to any recipe - tips, modifications, or memories.'**
  String get hintRecipeNotes;

  /// No description provided for @hintCookbookOrganization.
  ///
  /// In en, this message translates to:
  /// **'Create multiple cookbooks to organize your recipes by theme or occasion.'**
  String get hintCookbookOrganization;

  /// No description provided for @hintTagSystem.
  ///
  /// In en, this message translates to:
  /// **'Tag recipes for easy filtering - create custom tags like \'Quick\', \'Favorite\', etc.'**
  String get hintTagSystem;

  /// No description provided for @allergyMyAllergies.
  ///
  /// In en, this message translates to:
  /// **'My Allergies'**
  String get allergyMyAllergies;

  /// No description provided for @allergyDisabledTab.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get allergyDisabledTab;

  /// No description provided for @allergyNoDisabledTitle.
  ///
  /// In en, this message translates to:
  /// **'No Disabled Warnings'**
  String get allergyNoDisabledTitle;

  /// No description provided for @allergyNoDisabledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When you dismiss allergy warnings on recipes, they will appear here so you can restore them later.'**
  String get allergyNoDisabledSubtitle;

  /// No description provided for @allergyDisabledInfo.
  ///
  /// In en, this message translates to:
  /// **'These recipes have had their allergy warnings disabled. Tap to restore warnings.'**
  String get allergyDisabledInfo;

  /// No description provided for @trashRestoredMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" restored'**
  String trashRestoredMessage(String title);

  /// No description provided for @nutrientCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get nutrientCalories;

  /// No description provided for @nutrientTotalFat.
  ///
  /// In en, this message translates to:
  /// **'Total Fat'**
  String get nutrientTotalFat;

  /// No description provided for @nutrientSaturatedFat.
  ///
  /// In en, this message translates to:
  /// **'Saturated Fat'**
  String get nutrientSaturatedFat;

  /// No description provided for @nutrientTransFat.
  ///
  /// In en, this message translates to:
  /// **'Trans Fat'**
  String get nutrientTransFat;

  /// No description provided for @nutrientMonounsaturatedFat.
  ///
  /// In en, this message translates to:
  /// **'Monounsaturated Fat'**
  String get nutrientMonounsaturatedFat;

  /// No description provided for @nutrientPolyunsaturatedFat.
  ///
  /// In en, this message translates to:
  /// **'Polyunsaturated Fat'**
  String get nutrientPolyunsaturatedFat;

  /// No description provided for @nutrientCarbohydrates.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get nutrientCarbohydrates;

  /// No description provided for @nutrientFiber.
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get nutrientFiber;

  /// No description provided for @nutrientSugars.
  ///
  /// In en, this message translates to:
  /// **'Sugars'**
  String get nutrientSugars;

  /// No description provided for @nutrientProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get nutrientProtein;

  /// No description provided for @nutrientCholesterol.
  ///
  /// In en, this message translates to:
  /// **'Cholesterol'**
  String get nutrientCholesterol;

  /// No description provided for @nutrientSodium.
  ///
  /// In en, this message translates to:
  /// **'Sodium'**
  String get nutrientSodium;

  /// No description provided for @nutrientPotassium.
  ///
  /// In en, this message translates to:
  /// **'Potassium'**
  String get nutrientPotassium;

  /// No description provided for @nutrientCalcium.
  ///
  /// In en, this message translates to:
  /// **'Calcium'**
  String get nutrientCalcium;

  /// No description provided for @nutrientIron.
  ///
  /// In en, this message translates to:
  /// **'Iron'**
  String get nutrientIron;

  /// No description provided for @nutrientMagnesium.
  ///
  /// In en, this message translates to:
  /// **'Magnesium'**
  String get nutrientMagnesium;

  /// No description provided for @nutrientPhosphorus.
  ///
  /// In en, this message translates to:
  /// **'Phosphorus'**
  String get nutrientPhosphorus;

  /// No description provided for @nutrientZinc.
  ///
  /// In en, this message translates to:
  /// **'Zinc'**
  String get nutrientZinc;

  /// No description provided for @nutrientCopper.
  ///
  /// In en, this message translates to:
  /// **'Copper'**
  String get nutrientCopper;

  /// No description provided for @nutrientManganese.
  ///
  /// In en, this message translates to:
  /// **'Manganese'**
  String get nutrientManganese;

  /// No description provided for @nutrientSelenium.
  ///
  /// In en, this message translates to:
  /// **'Selenium'**
  String get nutrientSelenium;

  /// No description provided for @nutrientVitaminA.
  ///
  /// In en, this message translates to:
  /// **'Vitamin A'**
  String get nutrientVitaminA;

  /// No description provided for @nutrientVitaminC.
  ///
  /// In en, this message translates to:
  /// **'Vitamin C'**
  String get nutrientVitaminC;

  /// No description provided for @nutrientVitaminD.
  ///
  /// In en, this message translates to:
  /// **'Vitamin D'**
  String get nutrientVitaminD;

  /// No description provided for @nutrientVitaminE.
  ///
  /// In en, this message translates to:
  /// **'Vitamin E'**
  String get nutrientVitaminE;

  /// No description provided for @nutrientVitaminK.
  ///
  /// In en, this message translates to:
  /// **'Vitamin K'**
  String get nutrientVitaminK;

  /// No description provided for @nutrientThiaminB1.
  ///
  /// In en, this message translates to:
  /// **'Thiamin (B1)'**
  String get nutrientThiaminB1;

  /// No description provided for @nutrientRiboflavinB2.
  ///
  /// In en, this message translates to:
  /// **'Riboflavin (B2)'**
  String get nutrientRiboflavinB2;

  /// No description provided for @nutrientNiacinB3.
  ///
  /// In en, this message translates to:
  /// **'Niacin (B3)'**
  String get nutrientNiacinB3;

  /// No description provided for @nutrientPantothenicAcidB5.
  ///
  /// In en, this message translates to:
  /// **'Pantothenic Acid (B5)'**
  String get nutrientPantothenicAcidB5;

  /// No description provided for @nutrientVitaminB6.
  ///
  /// In en, this message translates to:
  /// **'Vitamin B6'**
  String get nutrientVitaminB6;

  /// No description provided for @nutrientVitaminB12.
  ///
  /// In en, this message translates to:
  /// **'Vitamin B12'**
  String get nutrientVitaminB12;

  /// No description provided for @nutrientFolate.
  ///
  /// In en, this message translates to:
  /// **'Folate'**
  String get nutrientFolate;

  /// No description provided for @nutrientCholine.
  ///
  /// In en, this message translates to:
  /// **'Choline'**
  String get nutrientCholine;

  /// No description provided for @nutrientCategoryMacronutrients.
  ///
  /// In en, this message translates to:
  /// **'Macronutrients'**
  String get nutrientCategoryMacronutrients;

  /// No description provided for @nutrientCategoryMinerals.
  ///
  /// In en, this message translates to:
  /// **'Minerals'**
  String get nutrientCategoryMinerals;

  /// No description provided for @nutrientCategoryVitamins.
  ///
  /// In en, this message translates to:
  /// **'Vitamins'**
  String get nutrientCategoryVitamins;

  /// No description provided for @nutrientCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get nutrientCarbs;

  /// No description provided for @nutrientFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get nutrientFat;

  /// No description provided for @nutritionKcalPerServing.
  ///
  /// In en, this message translates to:
  /// **'{count} kcal per serving'**
  String nutritionKcalPerServing(int count);

  /// No description provided for @nutritionKcalTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} kcal total'**
  String nutritionKcalTotal(int count);

  /// No description provided for @shareShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Share Shopping List'**
  String get shareShoppingList;

  /// No description provided for @shareOneTimeLink.
  ///
  /// In en, this message translates to:
  /// **'One-Time Link'**
  String get shareOneTimeLink;

  /// No description provided for @shareOneTimeLinkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Free • 24h expiry • View/download only'**
  String get shareOneTimeLinkSubtitle;

  /// No description provided for @shareGenerateLink.
  ///
  /// In en, this message translates to:
  /// **'Generate Link'**
  String get shareGenerateLink;

  /// No description provided for @shareFamilyShare.
  ///
  /// In en, this message translates to:
  /// **'Family Share'**
  String get shareFamilyShare;

  /// No description provided for @shareFamilySyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time sync • Per-member permissions'**
  String get shareFamilySyncSubtitle;

  /// No description provided for @shareFamilyCreateJoin.
  ///
  /// In en, this message translates to:
  /// **'Create or join a family to share'**
  String get shareFamilyCreateJoin;

  /// No description provided for @shareFamilyRequiresCloudSync.
  ///
  /// In en, this message translates to:
  /// **'Requires Cloud Sync subscription'**
  String get shareFamilyRequiresCloudSync;

  /// No description provided for @shareFamilyUpgradeMessage.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Cloud Sync to share cookbooks and lists with your family in real-time.'**
  String get shareFamilyUpgradeMessage;

  /// No description provided for @shareFamilySignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to use family sharing'**
  String get shareFamilySignIn;

  /// No description provided for @shareFamilySetupInSettings.
  ///
  /// In en, this message translates to:
  /// **'Create or join a family in Settings → Family Sharing'**
  String get shareFamilySetupInSettings;

  /// No description provided for @shareSharedWith.
  ///
  /// In en, this message translates to:
  /// **'Shared with'**
  String get shareSharedWith;

  /// No description provided for @shareRevoked.
  ///
  /// In en, this message translates to:
  /// **'Share revoked'**
  String get shareRevoked;

  /// No description provided for @shareSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in to create share links'**
  String get shareSignInRequired;

  /// No description provided for @shareCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create link'**
  String get shareCreateFailed;

  /// No description provided for @shareNoFamilyMembers.
  ///
  /// In en, this message translates to:
  /// **'No other family members to share with'**
  String get shareNoFamilyMembers;

  /// No description provided for @shareAddFamilyMembers.
  ///
  /// In en, this message translates to:
  /// **'Add family members'**
  String get shareAddFamilyMembers;

  /// No description provided for @shareWith.
  ///
  /// In en, this message translates to:
  /// **'Share with'**
  String get shareWith;

  /// No description provided for @shareSharedWithMember.
  ///
  /// In en, this message translates to:
  /// **'Shared with {name}'**
  String shareSharedWithMember(String name);

  /// No description provided for @shareShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to share'**
  String get shareShareFailed;

  /// No description provided for @shareLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied!'**
  String get shareLinkCopied;

  /// No description provided for @shareLinkExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Expires in {hours}h'**
  String shareLinkExpiresIn(int hours);

  /// No description provided for @shareRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get shareRevoke;

  /// No description provided for @shareUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get shareUpgrade;

  /// No description provided for @sharePermReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Read Only'**
  String get sharePermReadOnly;

  /// No description provided for @sharePermAddOnly.
  ///
  /// In en, this message translates to:
  /// **'Add Only'**
  String get sharePermAddOnly;

  /// No description provided for @sharePermFullEdit.
  ///
  /// In en, this message translates to:
  /// **'Full Edit'**
  String get sharePermFullEdit;

  /// No description provided for @sharePermFullAccess.
  ///
  /// In en, this message translates to:
  /// **'Full Access'**
  String get sharePermFullAccess;

  /// No description provided for @sharePermViewRecipes.
  ///
  /// In en, this message translates to:
  /// **'Can view recipes'**
  String get sharePermViewRecipes;

  /// No description provided for @sharePermAddRecipes.
  ///
  /// In en, this message translates to:
  /// **'Can add new recipes'**
  String get sharePermAddRecipes;

  /// No description provided for @sharePermEditRecipes.
  ///
  /// In en, this message translates to:
  /// **'Can edit any recipe'**
  String get sharePermEditRecipes;

  /// No description provided for @sharePermViewItems.
  ///
  /// In en, this message translates to:
  /// **'Can view items'**
  String get sharePermViewItems;

  /// No description provided for @sharePermAddItems.
  ///
  /// In en, this message translates to:
  /// **'Can add items, edit own'**
  String get sharePermAddItems;

  /// No description provided for @sharePermEditItems.
  ///
  /// In en, this message translates to:
  /// **'Can edit & delete items'**
  String get sharePermEditItems;

  /// No description provided for @shareUnknownMember.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get shareUnknownMember;

  /// No description provided for @subscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscriptionTitle;

  /// No description provided for @subscriptionUpgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get subscriptionUpgradeToPro;

  /// No description provided for @subscriptionUnlockFeatures.
  ///
  /// In en, this message translates to:
  /// **'Unlock cloud sync, smart import, and more.'**
  String get subscriptionUnlockFeatures;

  /// No description provided for @subscriptionViewPlans.
  ///
  /// In en, this message translates to:
  /// **'View Plans'**
  String get subscriptionViewPlans;

  /// No description provided for @subscriptionRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored successfully!'**
  String get subscriptionRestored;

  /// No description provided for @subscriptionNoPurchases.
  ///
  /// In en, this message translates to:
  /// **'No previous purchases found.'**
  String get subscriptionNoPurchases;

  /// No description provided for @subscriptionRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String subscriptionRestoreFailed(String error);

  /// No description provided for @subscriptionRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get subscriptionRestorePurchases;

  /// No description provided for @subscriptionCancelledUntil.
  ///
  /// In en, this message translates to:
  /// **'Cancelled — access until {date}'**
  String subscriptionCancelledUntil(String date);

  /// No description provided for @subscriptionRenews.
  ///
  /// In en, this message translates to:
  /// **'Renews'**
  String get subscriptionRenews;

  /// No description provided for @subscriptionPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get subscriptionPlan;

  /// No description provided for @subscriptionLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime — never expires'**
  String get subscriptionLifetime;

  /// No description provided for @subscriptionManage.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get subscriptionManage;

  /// No description provided for @subscriptionUnknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get subscriptionUnknownDate;

  /// No description provided for @subscriptionUpgradeToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro to unlock'**
  String get subscriptionUpgradeToUnlock;

  /// No description provided for @subscriptionProBadge.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get subscriptionProBadge;

  /// No description provided for @customThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Theme'**
  String get customThemeTitle;

  /// No description provided for @customThemeColors.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get customThemeColors;

  /// No description provided for @customThemeBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get customThemeBackground;

  /// No description provided for @customThemeBackgroundDesc.
  ///
  /// In en, this message translates to:
  /// **'App background, scaffold'**
  String get customThemeBackgroundDesc;

  /// No description provided for @customThemePrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get customThemePrimary;

  /// No description provided for @customThemePrimaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Buttons, highlights, app bar'**
  String get customThemePrimaryDesc;

  /// No description provided for @customThemeAccent.
  ///
  /// In en, this message translates to:
  /// **'Accent'**
  String get customThemeAccent;

  /// No description provided for @customThemeAccentDesc.
  ///
  /// In en, this message translates to:
  /// **'FAB, switches, secondary highlights'**
  String get customThemeAccentDesc;

  /// No description provided for @customThemeStartFromPreset.
  ///
  /// In en, this message translates to:
  /// **'Start from a preset'**
  String get customThemeStartFromPreset;

  /// No description provided for @customThemeLightMode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get customThemeLightMode;

  /// No description provided for @customThemeDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get customThemeDarkMode;

  /// No description provided for @customThemeLinkedOverlay.
  ///
  /// In en, this message translates to:
  /// **'Colors are auto-generated from your {mode} theme'**
  String customThemeLinkedOverlay(String mode);

  /// No description provided for @customThemeUnlockButton.
  ///
  /// In en, this message translates to:
  /// **'Customize colors'**
  String get customThemeUnlockButton;

  /// No description provided for @customThemeLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Link to {mode}'**
  String customThemeLinkButton(String mode);

  /// No description provided for @customThemeLivePreview.
  ///
  /// In en, this message translates to:
  /// **'Live Preview'**
  String get customThemeLivePreview;

  /// No description provided for @settingsUserFallback.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get settingsUserFallback;

  /// No description provided for @settingsManageSection.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get settingsManageSection;

  /// No description provided for @settingsExportNone.
  ///
  /// In en, this message translates to:
  /// **'None Selected'**
  String get settingsExportNone;

  /// No description provided for @settingsExportPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial Backup'**
  String get settingsExportPartial;

  /// No description provided for @settingsSystemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsSystemLanguage;

  /// No description provided for @tierFamily.
  ///
  /// In en, this message translates to:
  /// **'FAMILY'**
  String get tierFamily;

  /// No description provided for @tierCreator.
  ///
  /// In en, this message translates to:
  /// **'CREATOR'**
  String get tierCreator;

  /// No description provided for @tierFreeName.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get tierFreeName;

  /// No description provided for @tierPremiumName.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get tierPremiumName;

  /// No description provided for @tierCloudSyncName.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get tierCloudSyncName;

  /// No description provided for @tierCloudSyncFamilyName.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync Family'**
  String get tierCloudSyncFamilyName;

  /// No description provided for @tierCreatorName.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get tierCreatorName;

  /// No description provided for @nutritionEstimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated values'**
  String get nutritionEstimated;

  /// No description provided for @nutritionTipMatch.
  ///
  /// In en, this message translates to:
  /// **'Tap any ingredient to change its USDA food match'**
  String get nutritionTipMatch;

  /// No description provided for @nutritionTipManual.
  ///
  /// In en, this message translates to:
  /// **'Enter exact nutrition values if you know them'**
  String get nutritionTipManual;

  /// No description provided for @nutritionTipSpecific.
  ///
  /// In en, this message translates to:
  /// **'Choose specific types (e.g., \"all-purpose flour\" not just \"flour\")'**
  String get nutritionTipSpecific;

  /// No description provided for @nutritionTipSaved.
  ///
  /// In en, this message translates to:
  /// **'Your corrections are saved for future recipes'**
  String get nutritionTipSaved;

  /// No description provided for @nutritionGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get nutritionGotIt;

  /// No description provided for @nutritionScaleMultiplier.
  ///
  /// In en, this message translates to:
  /// **'Scale multiplier'**
  String get nutritionScaleMultiplier;

  /// No description provided for @nutritionScaleHelper.
  ///
  /// In en, this message translates to:
  /// **'1.0 = full recipe'**
  String get nutritionScaleHelper;

  /// No description provided for @nutritionOpenRecipe.
  ///
  /// In en, this message translates to:
  /// **'Open {title}'**
  String nutritionOpenRecipe(String title);

  /// No description provided for @nutrientCal.
  ///
  /// In en, this message translates to:
  /// **'Cal'**
  String get nutrientCal;

  /// No description provided for @nutrientSugar.
  ///
  /// In en, this message translates to:
  /// **'Sugar'**
  String get nutrientSugar;

  /// No description provided for @appearanceCustomThemeRequiresPremium.
  ///
  /// In en, this message translates to:
  /// **'Custom theme requires Premium'**
  String get appearanceCustomThemeRequiresPremium;

  /// No description provided for @appearancePremiumBadge.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get appearancePremiumBadge;

  /// No description provided for @substitutionsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get substitutionsAll;

  /// No description provided for @substitutionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} substitutes • {category}'**
  String substitutionsCount(int count, String category);

  /// No description provided for @colorPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a color'**
  String get colorPickerTitle;

  /// No description provided for @colorPickerHex.
  ///
  /// In en, this message translates to:
  /// **'Hex'**
  String get colorPickerHex;

  /// No description provided for @colorPickerSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get colorPickerSelect;

  /// No description provided for @scanSelectPages.
  ///
  /// In en, this message translates to:
  /// **'Select multiple pages'**
  String get scanSelectPages;

  /// No description provided for @scanNoTextPdf.
  ///
  /// In en, this message translates to:
  /// **'No text found in PDF. Try using a clearer scan or the Text paste option instead.'**
  String get scanNoTextPdf;

  /// No description provided for @scanLittleTextPdf.
  ///
  /// In en, this message translates to:
  /// **'Very little text detected in PDF ({count} characters). The scan may be too blurry. Try a higher quality PDF, or use the Text paste option instead.'**
  String scanLittleTextPdf(int count);

  /// No description provided for @scanNoTextImage.
  ///
  /// In en, this message translates to:
  /// **'No text found in image. Try taking the photo in better lighting, or use the Text paste option instead.'**
  String get scanNoTextImage;

  /// No description provided for @scanLittleTextImage.
  ///
  /// In en, this message translates to:
  /// **'Very little text detected ({count} characters). Try a clearer photo with better lighting, or use the Text paste option instead.'**
  String scanLittleTextImage(int count);

  /// No description provided for @scanProgress.
  ///
  /// In en, this message translates to:
  /// **'Scanning page {current} of {total}...'**
  String scanProgress(int current, int total);

  /// No description provided for @communityTagHint.
  ///
  /// In en, this message translates to:
  /// **'Add custom tag...'**
  String get communityTagHint;

  /// No description provided for @tagPickerOrganize.
  ///
  /// In en, this message translates to:
  /// **'Tags help you organize your recipes'**
  String get tagPickerOrganize;

  /// No description provided for @tagPickerLoadDefaults.
  ///
  /// In en, this message translates to:
  /// **'Load Default Tags'**
  String get tagPickerLoadDefaults;

  /// No description provided for @tagPickerExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Date Night'**
  String get tagPickerExampleHint;

  /// No description provided for @drawerProTier.
  ///
  /// In en, this message translates to:
  /// **'Pro · {tier}'**
  String drawerProTier(String tier);

  /// No description provided for @accountStoreFallback.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get accountStoreFallback;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'it', 'ja', 'ko', 'nl', 'pl', 'pt', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'it': return AppLocalizationsIt();
    case 'ja': return AppLocalizationsJa();
    case 'ko': return AppLocalizationsKo();
    case 'nl': return AppLocalizationsNl();
    case 'pl': return AppLocalizationsPl();
    case 'pt': return AppLocalizationsPt();
    case 'ru': return AppLocalizationsRu();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
