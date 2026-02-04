import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('es')
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

  /// No description provided for @settingsRPGMode.
  ///
  /// In en, this message translates to:
  /// **'RPG Mode'**
  String get settingsRPGMode;

  /// No description provided for @settingsRPGModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable fantasy-style text & images'**
  String get settingsRPGModeSubtitle;

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
  /// **'Shared from Recipe Spellbook ✨'**
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
  /// **'Importing {count} recipes...'**
  String importingRecipes(int count);

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
  /// **'App artwork that changes with RPG mode'**
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

  /// No description provided for @placeholderRpgInfo.
  ///
  /// In en, this message translates to:
  /// **'Default images change between normal and RPG variants when RPG Mode is enabled.'**
  String get placeholderRpgInfo;

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

  /// No description provided for @settingsRPGModeActive.
  ///
  /// In en, this message translates to:
  /// **'Conjuring magical text...'**
  String get settingsRPGModeActive;

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

  /// No description provided for @settingsRpgAnimations.
  ///
  /// In en, this message translates to:
  /// **'Rarity Animations'**
  String get settingsRpgAnimations;

  /// No description provided for @settingsRpgAnimationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Glowing effects for epic and legendary recipes'**
  String get settingsRpgAnimationsSubtitle;

  /// No description provided for @settingsRpgSounds.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get settingsRpgSounds;

  /// No description provided for @settingsRpgSoundsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play sounds for achievements and level ups'**
  String get settingsRpgSoundsSubtitle;

  /// No description provided for @settingsRpgAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get settingsRpgAchievements;

  /// No description provided for @settingsRpgAchievementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your unlocked achievements'**
  String get settingsRpgAchievementsSubtitle;

  /// No description provided for @settingsRpgStats.
  ///
  /// In en, this message translates to:
  /// **'Cooking Stats'**
  String get settingsRpgStats;

  /// No description provided for @settingsRpgStatsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your cooking statistics'**
  String get settingsRpgStatsSubtitle;

  /// No description provided for @settingsRpgModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Transform your cooking into an adventure!'**
  String get settingsRpgModeEnabled;

  /// No description provided for @settingsRecipeLayoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize how recipes are displayed'**
  String get settingsRecipeLayoutSubtitle;

  /// No description provided for @rarityCommon.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get rarityCommon;

  /// No description provided for @rarityCommonDesc.
  ///
  /// In en, this message translates to:
  /// **'A simple everyday recipe'**
  String get rarityCommonDesc;

  /// No description provided for @rarityUncommon.
  ///
  /// In en, this message translates to:
  /// **'Uncommon'**
  String get rarityUncommon;

  /// No description provided for @rarityUncommonDesc.
  ///
  /// In en, this message translates to:
  /// **'A tasty recipe with a twist'**
  String get rarityUncommonDesc;

  /// No description provided for @rarityRare.
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get rarityRare;

  /// No description provided for @rarityRareDesc.
  ///
  /// In en, this message translates to:
  /// **'A special recipe worth mastering'**
  String get rarityRareDesc;

  /// No description provided for @rarityEpic.
  ///
  /// In en, this message translates to:
  /// **'Epic'**
  String get rarityEpic;

  /// No description provided for @rarityEpicDesc.
  ///
  /// In en, this message translates to:
  /// **'An epic recipe of great power!'**
  String get rarityEpicDesc;

  /// No description provided for @rarityLegendary.
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get rarityLegendary;

  /// No description provided for @rarityLegendaryDesc.
  ///
  /// In en, this message translates to:
  /// **'A legendary recipe worthy of the gods!'**
  String get rarityLegendaryDesc;

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

  /// No description provided for @rpgMode.
  ///
  /// In en, this message translates to:
  /// **'RPG Mode'**
  String get rpgMode;

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
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
