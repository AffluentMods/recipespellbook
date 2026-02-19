// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Recipe Spellbook';

  @override
  String get navHome => 'Home';

  @override
  String get navCookbooks => 'Cookbooks';

  @override
  String get navPlanner => 'Planner';

  @override
  String get navShopping => 'Shopping';

  @override
  String get navSettings => 'Settings';

  @override
  String get homeGreeting => 'Welcome back!';

  @override
  String get homeQuickAccess => 'Quick Access';

  @override
  String get homeMealPlan => 'Today\'s Meals';

  @override
  String get homePinnedRecipes => 'Pinned Recipes';

  @override
  String get homeRecentRecipes => 'Recently Viewed';

  @override
  String get homeNoMealsPlanned => 'No meals planned for today';

  @override
  String get homeNoPinnedRecipes => 'No pinned recipes yet';

  @override
  String get homeNoRecentRecipes => 'No recent recipes';

  @override
  String get recipesTitle => 'Recipes';

  @override
  String get recipesEmpty => 'No recipes yet';

  @override
  String get recipesEmptySubtitle => 'Add your first recipe to get started';

  @override
  String get recipeAdd => 'Add Recipe';

  @override
  String get recipeEdit => 'Edit Recipe';

  @override
  String get recipeDelete => 'Delete Recipe';

  @override
  String get recipeDeleteConfirm => 'Are you sure you want to delete this recipe?';

  @override
  String get recipeFavorite => 'Add to favorites';

  @override
  String get recipeUnfavorite => 'Remove from favorites';

  @override
  String get recipePin => 'Pin recipe';

  @override
  String get recipeUnpin => 'Unpin recipe';

  @override
  String get recipeShare => 'Share recipe';

  @override
  String get recipePrint => 'Print recipe';

  @override
  String get recipeDuplicate => 'Duplicate recipe';

  @override
  String get recipeAddToMealPlan => 'Add to meal plan';

  @override
  String get recipeAddToShoppingList => 'Add to shopping list';

  @override
  String get recipeStartCooking => 'Start Cooking';

  @override
  String get recipeFieldTitle => 'Title';

  @override
  String get recipeFieldDescription => 'Description';

  @override
  String get recipeFieldIngredients => 'Ingredients';

  @override
  String get recipeFieldInstructions => 'Instructions';

  @override
  String get recipeFieldNotes => 'Notes';

  @override
  String get notesTitle => 'Notes';

  @override
  String get recipeFieldServings => 'Servings';

  @override
  String get recipeFieldPrepTime => 'Prep Time';

  @override
  String get recipeFieldCookTime => 'Cook Time';

  @override
  String get recipeFieldTotalTime => 'Total Time';

  @override
  String get recipeFieldSource => 'Source';

  @override
  String get recipeFieldCourse => 'Course';

  @override
  String get recipeFieldCategory => 'Category';

  @override
  String get recipeFieldTags => 'Tags';

  @override
  String get recipeFieldRating => 'Rating';

  @override
  String get ratingCommon => 'Common';

  @override
  String get ratingUncommon => 'Uncommon';

  @override
  String get ratingRare => 'Rare';

  @override
  String get ratingEpic => 'Epic';

  @override
  String get ratingLegendary => 'Legendary';

  @override
  String get ratingUnrated => 'Unrated';

  @override
  String get minutesAbbrev => 'min';

  @override
  String get hoursAbbrev => 'hr';

  @override
  String get servingsUnit => 'servings';

  @override
  String get ingredientsTitle => 'Ingredients';

  @override
  String get ingredientsEmpty => 'No ingredients added';

  @override
  String get ingredientAdd => 'Add ingredient';

  @override
  String get ingredientPlaceholder => 'e.g., 2 cups flour';

  @override
  String get instructionsTitle => 'Instructions';

  @override
  String get instructionsEmpty => 'No instructions added';

  @override
  String get instructionAdd => 'Add step';

  @override
  String get instructionPlaceholder => 'Describe this step...';

  @override
  String stepNumber(int number) {
    return 'Step $number';
  }

  @override
  String get cookbooksTitle => 'Cookbooks';

  @override
  String get cookbooksEmpty => 'No cookbooks yet';

  @override
  String get cookbookAdd => 'New Cookbook';

  @override
  String get cookbookEdit => 'Edit Cookbook';

  @override
  String get cookbookDelete => 'Delete Cookbook';

  @override
  String get cookbookDeleteConfirm => 'Delete this cookbook and all its recipes?';

  @override
  String cookbookRecipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipes',
      one: '1 recipe',
      zero: 'No recipes',
    );
    return '$_temp0';
  }

  @override
  String get shoppingDeli => 'Deli';

  @override
  String get shoppingCannedGoods => 'Canned Goods & Soups';

  @override
  String get shoppingCondiments => 'Condiments & Sauces';

  @override
  String get shoppingGrainsAndPasta => 'Grains, Pasta & Rice';

  @override
  String get shoppingCookingAndBaking => 'Cooking & Baking';

  @override
  String get shoppingBreakfastCereal => 'Breakfast & Cereal';

  @override
  String get shoppingBeerWineSpirits => 'Beer, Wine & Spirits';

  @override
  String get shoppingBaby => 'Baby';

  @override
  String get shoppingPet => 'Pet';

  @override
  String get shoppingHousehold => 'Household';

  @override
  String get shoppingPersonalCare => 'Personal Care';

  @override
  String get plannerTitle => 'Meal Planner';

  @override
  String get plannerEmpty => 'No meals planned';

  @override
  String get plannerEmptySubtitle => 'Tap + to add a meal for this day';

  @override
  String get plannerAddMeal => 'Add Meal';

  @override
  String get plannerToday => 'Today';

  @override
  String get plannerThisWeek => 'This Week';

  @override
  String get plannerBreakfast => 'Breakfast';

  @override
  String get plannerLunch => 'Lunch';

  @override
  String get plannerDinner => 'Dinner';

  @override
  String get plannerSnack => 'Snack';

  @override
  String get shoppingTitle => 'Shopping List';

  @override
  String get shoppingEmpty => 'Your list is empty';

  @override
  String get shoppingEmptySubtitle => 'Add items or import from recipes';

  @override
  String get shoppingAddItem => 'Add item...';

  @override
  String get shoppingCheckedItems => 'Checked Items';

  @override
  String get shoppingClearChecked => 'Clear checked items';

  @override
  String get shoppingClearAll => 'Clear all items';

  @override
  String get shoppingCategories => 'Shopping Categories';

  @override
  String get shoppingUncategorized => 'Uncategorized';

  @override
  String shoppingItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeMode => 'Theme Mode';

  @override
  String get settingsThemeModeSystem => 'System';

  @override
  String get settingsThemeModeLight => 'Light';

  @override
  String get settingsThemeModeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsMeasurements => 'Measurements';

  @override
  String get settingsMeasurementsUS => 'US (cups, oz)';

  @override
  String get settingsMeasurementsMetric => 'Metric (ml, g)';

  @override
  String get settingsRPGMode => 'RPG Mode';

  @override
  String get settingsRPGModeSubtitle => 'Enable fantasy-style text & images';

  @override
  String get settingsRecipes => 'Recipes';

  @override
  String get settingsManageCourses => 'Manage Courses';

  @override
  String get settingsManageCategories => 'Manage Categories';

  @override
  String get settingsManageTags => 'Manage Tags';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsExport => 'Export Data';

  @override
  String get settingsExportSubtitle => 'Backup your recipes';

  @override
  String get settingsImport => 'Import Data';

  @override
  String get settingsImportSubtitle => 'Restore from backup';

  @override
  String get settingsImportFromApps => 'Import from Other Apps';

  @override
  String get settingsImportFromAppsSubtitle => 'Paprika, Crouton, Mela & more';

  @override
  String get settingsAbout => 'About';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsPrivacy => 'Privacy Policy';

  @override
  String get settingsTerms => 'Terms of Service';

  @override
  String get settingsFeedback => 'Send Feedback';

  @override
  String get importTitle => 'Import';

  @override
  String get importCreate => 'Create';

  @override
  String get importCreateSubtitle => 'Write your own recipe';

  @override
  String get importSubtitle => 'From URL, image, or file';

  @override
  String get importChooseMethod => 'How would you like to add your recipe?';

  @override
  String get importProgress => 'Importing recipe...';

  @override
  String get importFromURL => 'From URL';

  @override
  String get importFromImage => 'From Image';

  @override
  String get importFromFile => 'From File';

  @override
  String get importFromText => 'Import from Text';

  @override
  String get importProcessing => 'Processing...';

  @override
  String get importSuccess => 'Recipe imported successfully';

  @override
  String get importError => 'Failed to import recipe';

  @override
  String get importBulkTitle => 'Import Recipes';

  @override
  String importBulkFound(int count) {
    return 'Found $count recipes';
  }

  @override
  String get importBulkImportAll => 'Import All';

  @override
  String get importBulkImportFirst => 'Import First';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search recipes...';

  @override
  String get searchNoResults => 'No recipes found';

  @override
  String get searchFilters => 'Filters';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionDone => 'Done';

  @override
  String get actionClose => 'Close';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionCopy => 'Copy';

  @override
  String get actionPaste => 'Paste';

  @override
  String get actionOk => 'OK';

  @override
  String get actionShare => 'Share';

  @override
  String get actionClear => 'Clear';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get errorNetwork => 'Network error. Please check your connection.';

  @override
  String get errorNotFound => 'Not found';

  @override
  String get errorInvalidURL => 'Invalid URL';

  @override
  String get successSaved => 'Saved successfully';

  @override
  String get successDeleted => 'Deleted successfully';

  @override
  String get successCopied => 'Copied to clipboard';

  @override
  String get confirmDeleteTitle => 'Confirm Delete';

  @override
  String get confirmDeleteMessage => 'This action cannot be undone.';

  @override
  String get emptyStateTitle => 'Nothing here yet';

  @override
  String get emptyStateSubtitle => 'Get started by adding your first item';

  @override
  String get dateToday => 'Today';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String get dateTomorrow => 'Tomorrow';

  @override
  String timeMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'minutes',
      one: 'minute',
    );
    return '$count $_temp0';
  }

  @override
  String timeHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hours',
      one: 'hour',
    );
    return '$count $_temp0';
  }

  @override
  String get trashTitle => 'Trash';

  @override
  String get trashEmpty => 'Trash is empty';

  @override
  String get trashEmptySubtitle => 'Deleted recipes will appear here for 30 days';

  @override
  String get trashRestore => 'Restore';

  @override
  String get trashRestored => 'restored';

  @override
  String get trashDeletePermanently => 'Delete permanently';

  @override
  String get trashEmptyTrash => 'Empty trash';

  @override
  String get trashEmptyConfirm => 'This will permanently delete all recipes in the trash. This action cannot be undone.';

  @override
  String get trashEmptied => 'Trash emptied';

  @override
  String get trashDeleted => 'Deleted';

  @override
  String get trashDeletedToday => 'Deleted today';

  @override
  String get trashDeletedYesterday => 'Deleted yesterday';

  @override
  String trashDeletedDaysAgo(int days) {
    return 'Deleted $days days ago';
  }

  @override
  String get trashExpiresToday => 'Expires today';

  @override
  String trashDaysLeft(int days) {
    return '$days days left';
  }

  @override
  String get cookingModeTitle => 'Cooking Mode';

  @override
  String get cookingSetTimer => 'Set Timer';

  @override
  String get cookingTimerDone => 'Timer Done!';

  @override
  String get cookingTimerFinished => 'Your timer has finished.';

  @override
  String get cookingExitTitle => 'Exit Cooking Mode?';

  @override
  String get cookingExitMessage => 'Your progress will be lost.';

  @override
  String get cookingExit => 'Exit';

  @override
  String get cookingFinish => 'Finish';

  @override
  String get taxonomyAddCourse => 'Add Course';

  @override
  String get taxonomyEditCourse => 'Edit Course';

  @override
  String get taxonomyDeleteCourse => 'Delete Course?';

  @override
  String get taxonomyAddCategory => 'Add Category';

  @override
  String get taxonomyEditCategory => 'Edit Category';

  @override
  String get taxonomyDeleteCategory => 'Delete Category?';

  @override
  String get taxonomyBuiltIn => 'Built-in';

  @override
  String get taxonomyCustom => 'Custom';

  @override
  String get taxonomyRestoreDefaults => 'Restore Defaults';

  @override
  String get taxonomyDefaultsRestored => 'Custom items deleted, defaults restored';

  @override
  String get taxonomyCourseName => 'Course Name';

  @override
  String get taxonomyCourseNameHint => 'e.g., Brunch, Appetizer';

  @override
  String get taxonomyCategoryName => 'Category Name';

  @override
  String get taxonomyCategoryNameHint => 'e.g., Gluten-Free, Low-Carb';

  @override
  String get taxonomyEmojiHint => 'Tap the emoji field to change it';

  @override
  String taxonomyDeleteCourseMessage(String name) {
    return 'Delete \"$name\"? Recipes using this course will become uncategorized.';
  }

  @override
  String taxonomyDeleteCategoryMessage(String name) {
    return 'Delete \"$name\"? Recipes using this category will become uncategorized.';
  }

  @override
  String get settingsQuickAccess => 'Quick Access';

  @override
  String get settingsPlaceholders => 'Image Placeholders';

  @override
  String get actionView => 'View';

  @override
  String get browseViewAll => 'View All Recipes';

  @override
  String browseRecipesTotal(int count) {
    return '$count recipes total';
  }

  @override
  String get browseCourses => 'Courses';

  @override
  String get browseCategories => 'Categories';

  @override
  String get browseNoCourse => 'No Course';

  @override
  String get browseUncategorized => 'Uncategorized';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesEmpty => 'No favorite recipes yet';

  @override
  String get favoritesEmptySubtitle => 'Tap the star on any recipe to add it here';

  @override
  String get favoritesRemoved => 'Removed from favorites';

  @override
  String get recentTitle => 'Recently Viewed';

  @override
  String get recentEmpty => 'No recently viewed recipes';

  @override
  String get recentEmptySubtitle => 'Recipes you view will appear here';

  @override
  String get recentJustNow => 'Just now';

  @override
  String recentMinutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String recentHoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String get recentYesterday => 'Yesterday';

  @override
  String recentDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get importFromUrl => 'Import from URL';

  @override
  String get importUrlHint => 'Recipe URL';

  @override
  String get importUrlPlaceholder => 'https://example.com/recipe';

  @override
  String get importFetch => 'Fetch Recipe';

  @override
  String get importFetching => 'Fetching...';

  @override
  String get importPreview => 'Preview';

  @override
  String get importRecipeFound => 'Recipe found!';

  @override
  String get importReviewSave => 'Review & Save';

  @override
  String get importEditBeforeSave => 'You can edit the recipe before saving';

  @override
  String get importSupportedSites => 'Supported Sites';

  @override
  String get importSupportedSitesInfo => 'Works with most recipe sites including AllRecipes, Food Network, Tasty, BBC Good Food, Epicurious, Serious Eats, Bon Appétit, and many more!';

  @override
  String get importFromScan => 'Scan Recipe';

  @override
  String get importFromPdf => 'Import from PDF';

  @override
  String get cookbookNew => 'New Cookbook';

  @override
  String get cookbookNameLabel => 'Cookbook Name';

  @override
  String get cookbookNameHint => 'e.g., Family Favorites';

  @override
  String get cookbookDescLabel => 'Description';

  @override
  String get cookbookDescHint => 'A collection of recipes...';

  @override
  String get cookbookAddCover => 'Add Cover';

  @override
  String get cookbookTapToAdd => 'Tap to add cover image';

  @override
  String get cookbookDeleteTitle => 'Delete Cookbook?';

  @override
  String cookbookDeleteMessage(int count) {
    return 'This cookbook contains $count recipes. They will be moved to trash.';
  }

  @override
  String get cookbookCannotDelete => 'Cannot delete your only cookbook';

  @override
  String get fontSizeTitle => 'Text Size';

  @override
  String get fontSizeReset => 'Reset to Default';

  @override
  String get fontSizeSmaller => 'Smaller text';

  @override
  String get fontSizeLarger => 'Larger text';

  @override
  String get defaultCookbookName => 'My Recipes';

  @override
  String get defaultCookbookDescription => 'Your personal recipe collection';

  @override
  String get defaultShoppingListName => 'Shopping List';

  @override
  String get courseBreakfast => 'Breakfast';

  @override
  String get courseLunch => 'Lunch';

  @override
  String get courseDinner => 'Dinner';

  @override
  String get courseAppetizer => 'Appetizer';

  @override
  String get courseSoup => 'Soup';

  @override
  String get courseSalad => 'Salad';

  @override
  String get courseMain => 'Main Course';

  @override
  String get courseSide => 'Side Dish';

  @override
  String get courseDessert => 'Dessert';

  @override
  String get courseSnack => 'Snack';

  @override
  String get courseBeverage => 'Beverage';

  @override
  String get categoryQuick => 'Quick & Easy';

  @override
  String get categoryHealthy => 'Healthy';

  @override
  String get categoryComfort => 'Comfort Food';

  @override
  String get categoryVegetarian => 'Vegetarian';

  @override
  String get categoryVegan => 'Vegan';

  @override
  String get categoryGlutenFree => 'Gluten-Free';

  @override
  String get categoryDairyFree => 'Dairy-Free';

  @override
  String get categoryLowCarb => 'Low Carb';

  @override
  String get categorySpicy => 'Spicy';

  @override
  String get categoryFamilyFriendly => 'Family Friendly';

  @override
  String get categoryParty => 'Party';

  @override
  String get categoryHoliday => 'Holiday';

  @override
  String get categoryBbq => 'BBQ & Grill';

  @override
  String get categoryBaking => 'Baking';

  @override
  String get shoppingProduce => 'Produce';

  @override
  String get shoppingDairy => 'Dairy & Eggs';

  @override
  String get shoppingMeat => 'Meat & Poultry';

  @override
  String get shoppingSeafood => 'Seafood';

  @override
  String get shoppingBakery => 'Bakery';

  @override
  String get shoppingFrozen => 'Frozen';

  @override
  String get shoppingPantry => 'Pantry';

  @override
  String get shoppingSpices => 'Spices & Seasonings';

  @override
  String get shoppingBeverages => 'Beverages';

  @override
  String get shoppingSnacks => 'Snacks';

  @override
  String get shoppingInternational => 'International';

  @override
  String get shoppingOther => 'Other';

  @override
  String get unitCup => 'cup';

  @override
  String get unitCups => 'cups';

  @override
  String get unitTablespoon => 'tablespoon';

  @override
  String get unitTablespoonAbbrev => 'tbsp';

  @override
  String get unitTeaspoon => 'teaspoon';

  @override
  String get unitTeaspoonAbbrev => 'tsp';

  @override
  String get unitFluidOunce => 'fluid ounce';

  @override
  String get unitFluidOunceAbbrev => 'fl oz';

  @override
  String get unitPint => 'pint';

  @override
  String get unitQuart => 'quart';

  @override
  String get unitGallon => 'gallon';

  @override
  String get unitMilliliter => 'milliliter';

  @override
  String get unitMilliliterAbbrev => 'ml';

  @override
  String get unitLiter => 'liter';

  @override
  String get unitLiterAbbrev => 'L';

  @override
  String get unitOunce => 'ounce';

  @override
  String get unitOunceAbbrev => 'oz';

  @override
  String get unitPound => 'pound';

  @override
  String get unitPoundAbbrev => 'lb';

  @override
  String get unitGram => 'gram';

  @override
  String get unitGramAbbrev => 'g';

  @override
  String get unitKilogram => 'kilogram';

  @override
  String get unitKilogramAbbrev => 'kg';

  @override
  String get unitPinch => 'pinch';

  @override
  String get unitDash => 'dash';

  @override
  String get unitClove => 'clove';

  @override
  String get unitCloves => 'cloves';

  @override
  String get unitHead => 'head';

  @override
  String get unitBunch => 'bunch';

  @override
  String get unitCan => 'can';

  @override
  String get unitPackage => 'package';

  @override
  String get unitSlice => 'slice';

  @override
  String get unitSlices => 'slices';

  @override
  String get unitPiece => 'piece';

  @override
  String get unitPieces => 'pieces';

  @override
  String get unitWhole => 'whole';

  @override
  String get unitLarge => 'large';

  @override
  String get unitMedium => 'medium';

  @override
  String get unitSmall => 'small';

  @override
  String get unitFahrenheit => '°F';

  @override
  String get unitCelsius => '°C';

  @override
  String get unitInch => 'inch';

  @override
  String get unitInches => 'inches';

  @override
  String get unitInchAbbrev => 'in';

  @override
  String get unitCentimeter => 'centimeter';

  @override
  String get unitCentimeterAbbrev => 'cm';

  @override
  String get unitMillimeter => 'millimeter';

  @override
  String get unitMillimeterAbbrev => 'mm';

  @override
  String get convertUnitsTitle => 'Convert Units';

  @override
  String get convertMetricToImperial => 'Metric → Imperial';

  @override
  String get convertMetricToImperialDesc => 'ml → fl oz, g → oz, kg → lb';

  @override
  String get convertImperialToMetric => 'Imperial → Metric';

  @override
  String get convertImperialToMetricDesc => 'cups → ml, oz → g, tsp → ml';

  @override
  String get convertResetToOriginal => 'Reset to Original';

  @override
  String get settingsRecipeLayout => 'Recipe Layout';

  @override
  String get settingsRecipeLayoutDescription => 'Choose how ingredients and instructions are displayed';

  @override
  String get settingsRecipeDisplay => 'Recipe Display';

  @override
  String get layoutStacked => 'Stacked';

  @override
  String get layoutStackedDescription => 'Show all content in a scrollable list';

  @override
  String get layoutTabbed => 'Tabbed';

  @override
  String get layoutTabbedDescription => 'Swipe between ingredients and instructions';

  @override
  String get recipeSwipeHint => 'Swipe to switch sections';

  @override
  String get recipeIngredients => 'Ingredients';

  @override
  String get recipeInstructions => 'Instructions';

  @override
  String get dateNextWeek => 'Next week';

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String timeWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks ago',
      one: '1 week ago',
    );
    return '$_temp0';
  }

  @override
  String timeMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }

  @override
  String timeYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years ago',
      one: '1 year ago',
    );
    return '$_temp0';
  }

  @override
  String timeInMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return 'in $_temp0';
  }

  @override
  String timeInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return 'in $_temp0';
  }

  @override
  String durationMinutes(int count) {
    return '$count min';
  }

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hrs',
      one: '1 hr',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours hr $minutes min';
  }

  @override
  String countRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipes',
      one: '1 recipe',
      zero: 'No recipes',
    );
    return '$_temp0';
  }

  @override
  String countIngredients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredients',
      one: '1 ingredient',
      zero: 'No ingredients',
    );
    return '$_temp0';
  }

  @override
  String countSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
      zero: 'No steps',
    );
    return '$_temp0';
  }

  @override
  String countItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String countSelected(int count) {
    return '$count selected';
  }

  @override
  String get errorGenericTitle => 'Error';

  @override
  String get errorGenericMessage => 'Something went wrong. Please try again.';

  @override
  String get errorNetworkTitle => 'Connection Error';

  @override
  String get errorNetworkMessage => 'Please check your internet connection and try again.';

  @override
  String get errorNotFoundTitle => 'Not Found';

  @override
  String get errorNotFoundMessage => 'The requested content could not be found.';

  @override
  String get errorInvalidUrlTitle => 'Invalid URL';

  @override
  String get errorInvalidUrlMessage => 'Please enter a valid URL starting with http:// or https://';

  @override
  String get errorPermissionDenied => 'Permission denied';

  @override
  String get errorStorageFull => 'Storage is full';

  @override
  String get errorFileNotFound => 'File not found';

  @override
  String get errorUnsupportedFormat => 'Unsupported file format';

  @override
  String get errorParsingFailed => 'Failed to parse content';

  @override
  String get errorSaveFailed => 'Failed to save';

  @override
  String get errorLoadFailed => 'Failed to load';

  @override
  String get errorDeleteFailed => 'Failed to delete';

  @override
  String get errorImportFailed => 'Failed to import';

  @override
  String get errorExportFailed => 'Failed to export';

  @override
  String get errorCameraAccess => 'Cannot access camera';

  @override
  String get errorGalleryAccess => 'Cannot access photo library';

  @override
  String get errorTimeout => 'Request timed out';

  @override
  String get errorServerError => 'Server error. Please try again later.';

  @override
  String get errorNoRecipeFound => 'No recipe data found on this page';

  @override
  String get errorInvalidRecipe => 'Invalid recipe data';

  @override
  String get errorDuplicateRecipe => 'This recipe already exists';

  @override
  String get validationRequired => 'This field is required';

  @override
  String validationTooShort(int min) {
    return 'Must be at least $min characters';
  }

  @override
  String validationTooLong(int max) {
    return 'Must be less than $max characters';
  }

  @override
  String get validationInvalidEmail => 'Please enter a valid email';

  @override
  String get validationInvalidUrl => 'Please enter a valid URL';

  @override
  String get validationInvalidNumber => 'Please enter a valid number';

  @override
  String validationMinValue(int min) {
    return 'Must be at least $min';
  }

  @override
  String validationMaxValue(int max) {
    return 'Must be at most $max';
  }

  @override
  String get photoTakePhoto => 'Take Photo';

  @override
  String get photoChooseFromGallery => 'Choose from Gallery';

  @override
  String get photoRemoveImage => 'Remove Image';

  @override
  String get shareAsText => 'Text';

  @override
  String get shareAsImage => 'Image';

  @override
  String get shareAsFile => 'Share as File';

  @override
  String get shareQrCode => 'Recipe QR Code';

  @override
  String get languageSystem => 'System Default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get scalingOriginal => 'Original';

  @override
  String get scalingHalf => 'Half';

  @override
  String get scalingDouble => 'Double';

  @override
  String get scalingTriple => 'Triple';

  @override
  String get scalingCustom => 'Custom';

  @override
  String scalingServings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count servings',
      one: '1 serving',
    );
    return '$_temp0';
  }

  @override
  String get importRecipe => 'Import Recipe';

  @override
  String get importFile => 'File';

  @override
  String get importImage => 'Image';

  @override
  String get importPaste => 'Paste';

  @override
  String get importPasteUrl => 'Paste recipe URL';

  @override
  String get importOr => 'OR';

  @override
  String get importSupportsFormats => 'Supports Paprika, Mela, JSON, ZIP exports';

  @override
  String get importFromSocialMedia => 'Import your recipes from any social media platform or website.';

  @override
  String get tagsTitle => 'Tags';

  @override
  String get tagsSelect => 'Select Tags';

  @override
  String get tagsNoTags => 'No tags yet';

  @override
  String get tagsCreate => 'Create Tag';

  @override
  String get tagsCreateNew => 'Create new tag';

  @override
  String get tagsEnterName => 'Enter tag name';

  @override
  String get tagsSearch => 'Search tags...';

  @override
  String get tagsSuggested => 'Suggested Tags';

  @override
  String get tagsRecent => 'Recently Used';

  @override
  String get tagsAll => 'All Tags';

  @override
  String get tagVegetarian => 'Vegetarian';

  @override
  String get tagVegan => 'Vegan';

  @override
  String get tagGlutenFree => 'Gluten-Free';

  @override
  String get tagDairyFree => 'Dairy-Free';

  @override
  String get tagNutFree => 'Nut-Free';

  @override
  String get tagLowCarb => 'Low Carb';

  @override
  String get tagKeto => 'Keto';

  @override
  String get tagPaleo => 'Paleo';

  @override
  String get tagWhole30 => 'Whole30';

  @override
  String get tagQuick => 'Quick';

  @override
  String get tagEasy => 'Easy';

  @override
  String get tagHealthy => 'Healthy';

  @override
  String get tagComfortFood => 'Comfort Food';

  @override
  String get tagFamilyFriendly => 'Family Friendly';

  @override
  String get tagKidFriendly => 'Kid Friendly';

  @override
  String get tagMealPrep => 'Meal Prep';

  @override
  String get tagOnePot => 'One Pot';

  @override
  String get tagInstantPot => 'Instant Pot';

  @override
  String get tagSlowCooker => 'Slow Cooker';

  @override
  String get tagAirFryer => 'Air Fryer';

  @override
  String get tagGrill => 'Grill';

  @override
  String get tagBBQ => 'BBQ';

  @override
  String get tagHoliday => 'Holiday';

  @override
  String get tagParty => 'Party';

  @override
  String get tagBudget => 'Budget';

  @override
  String get tagSpicy => 'Spicy';

  @override
  String get tagSweet => 'Sweet';

  @override
  String get tagSavory => 'Savory';

  @override
  String get tagLight => 'Light';

  @override
  String get tagHearty => 'Hearty';

  @override
  String get tagSummer => 'Summer';

  @override
  String get tagWinter => 'Winter';

  @override
  String get tagFall => 'Fall';

  @override
  String get tagSpring => 'Spring';

  @override
  String get settingsImagePlaceholders => 'Image Placeholders';

  @override
  String get settingsImagePlaceholdersSubtitle => 'Choose what shows when images are missing';

  @override
  String get settingsQuickAccessSubtitle => 'Configure what appears in Quick Access';

  @override
  String get settingsManageCoursesSubtitle => 'Add, edit, or remove courses';

  @override
  String get settingsManageCategoriesSubtitle => 'Add, edit, or remove categories';

  @override
  String get settingsShoppingCategories => 'Shopping Categories';

  @override
  String get settingsShoppingCategoriesSubtitle => 'Organize items by aisle';

  @override
  String get shoppingIngredientMappings => 'Ingredient Mappings';

  @override
  String shoppingPriority(int priority) {
    return 'Priority: $priority';
  }

  @override
  String get shoppingAddCategory => 'Add Category';

  @override
  String get shoppingEditCategory => 'Edit Category';

  @override
  String get shoppingDeleteCategory => 'Delete Category?';

  @override
  String shoppingDeleteCategoryMessage(String name) {
    return 'Delete \"$name\"? Items in this category will become uncategorized.';
  }

  @override
  String get shoppingCategoryName => 'Name';

  @override
  String get shoppingSearchIngredients => 'Search ingredients...';

  @override
  String shoppingMappingsInfo(int count) {
    return 'Tap the category to change where an ingredient goes. ($count mappings)';
  }

  @override
  String shoppingCategoryFor(String ingredient) {
    return 'Category for \"$ingredient\"';
  }

  @override
  String shoppingMovedTo(String ingredient, String category) {
    return '\"$ingredient\" moved to $category';
  }

  @override
  String shoppingResetToDefault(String ingredient) {
    return '\"$ingredient\" reset to default';
  }

  @override
  String get actionReset => 'Reset';

  @override
  String shoppingMappingMoved(String ingredient, String category) {
    return '\"$ingredient\" moved to $category';
  }

  @override
  String shoppingMappingReset(String ingredient) {
    return '\"$ingredient\" reset to default';
  }

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get addPhotoSubtitle => 'Tap to select from gallery or camera';

  @override
  String get viewAllRecipes => 'View All Recipes';

  @override
  String recipesTotal(int count) {
    return '$count recipes total';
  }

  @override
  String get coursesTitle => 'Courses';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get courseBrunch => 'Brunch';

  @override
  String get courseMainDish => 'Main Dish';

  @override
  String get courseSideDish => 'Side Dish';

  @override
  String get courseSauce => 'Sauce';

  @override
  String get courseBread => 'Bread';

  @override
  String get categoryBean => 'Bean';

  @override
  String get categoryBread => 'Bread';

  @override
  String get categoryBurritoTaco => 'Burrito/Taco';

  @override
  String get categoryCasserole => 'Casserole';

  @override
  String get categoryChickenSteakMeat => 'Chicken/Steak/Meat';

  @override
  String get categoryDessert => 'Dessert';

  @override
  String get categoryFish => 'Fish';

  @override
  String get categoryFruit => 'Fruit';

  @override
  String get categoryPasta => 'Pasta';

  @override
  String get categoryPizza => 'Pizza';

  @override
  String get categoryPork => 'Pork';

  @override
  String get categoryRice => 'Rice';

  @override
  String get categorySandwich => 'Sandwich';

  @override
  String get categorySeafood => 'Seafood';

  @override
  String get categorySoup => 'Soup';

  @override
  String get categoryVegetable => 'Vegetable';

  @override
  String get or => 'or';

  @override
  String get and => 'and';

  @override
  String get wordOf => 'of';

  @override
  String get items => 'items';

  @override
  String get more => 'more';

  @override
  String get less => 'less';

  @override
  String get all => 'All';

  @override
  String get none => 'None';

  @override
  String get other => 'Other';

  @override
  String get custom => 'Custom';

  @override
  String get defaultValue => 'Default';

  @override
  String get required => 'Required';

  @override
  String get optional => 'Optional';

  @override
  String get photoChooseGallery => 'Choose from Gallery';

  @override
  String get importFirstRecipe => 'Import First';

  @override
  String get importAllRecipes => 'Import All';

  @override
  String get parseRecipe => 'Parse Recipe';

  @override
  String get shareRecipe => 'Share Recipe';

  @override
  String get shareExport => 'Export';

  @override
  String shareServings(int count) {
    return 'Servings: $count';
  }

  @override
  String sharePrep(int minutes) {
    return 'Prep: $minutes min';
  }

  @override
  String shareCook(int minutes) {
    return 'Cook: $minutes min';
  }

  @override
  String get shareFromApp => 'Shared from Recipe Spellbook ✨';

  @override
  String get shareCreatingCard => 'Creating recipe card...';

  @override
  String shareCheckRecipe(String title) {
    return 'Check out this recipe: $title';
  }

  @override
  String shareErrorImage(String error) {
    return 'Error creating image: $error';
  }

  @override
  String get editItem => 'Edit Item';

  @override
  String get selectAll => 'Select All';

  @override
  String get selectNone => 'Select None';

  @override
  String get viewPlanner => 'View Planner';

  @override
  String get planNow => 'Plan Now';

  @override
  String get loadingText => 'Loading...';

  @override
  String get errorText => 'Error';

  @override
  String get errorLoadingMeals => 'Error loading meals';

  @override
  String get readingImage => 'Reading image...';

  @override
  String get parsingRecipe => 'Parsing recipe...';

  @override
  String get noTextInImage => 'No text found in image';

  @override
  String failedProcessImage(String error) {
    return 'Failed to process image: $error';
  }

  @override
  String get cookingModeExit => 'Exit Cooking Mode';

  @override
  String cookingModeStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get cookingModePrevious => 'Previous';

  @override
  String get cookingModeNext => 'Next';

  @override
  String get cookingModeFinish => 'Finish';

  @override
  String get cookingModeCompleted => 'Recipe Completed!';

  @override
  String get cookingModeGreatJob => 'Great job! Enjoy your meal.';

  @override
  String get mealPlanBreakfast => 'Breakfast';

  @override
  String get mealPlanLunch => 'Lunch';

  @override
  String get mealPlanDinner => 'Dinner';

  @override
  String get mealPlanSnack => 'Snack';

  @override
  String get mealPlanAddMeal => 'Add Meal';

  @override
  String get mealPlanRemove => 'Remove from Plan';

  @override
  String get mealPlanNoMeals => 'No meals planned';

  @override
  String get mealPlanTapToAdd => 'Tap + to add a meal';

  @override
  String get thisWeek => 'This Week';

  @override
  String get itemName => 'Item name';

  @override
  String get addToShoppingList => 'Add to Shopping List';

  @override
  String get addToList => 'Add to list';

  @override
  String addedItemsToList(int count) {
    return 'Added $count items to shopping list';
  }

  @override
  String get scanToImport => 'Scan to import recipe';

  @override
  String xOfY(int current, int total) {
    return '$current of $total';
  }

  @override
  String addItems(int count) {
    return 'Add $count Items';
  }

  @override
  String failedToParse(String error) {
    return 'Failed to parse: $error';
  }

  @override
  String failedToImport(String error) {
    return 'Failed to import: $error';
  }

  @override
  String get groupBy => 'Group by';

  @override
  String get cookbookHint => 'Tap to select • Long press to edit';

  @override
  String get rename => 'Rename';

  @override
  String get renameCookbook => 'Rename Cookbook';

  @override
  String get seeAll => 'See all';

  @override
  String get imagePlaceholders => 'Image Placeholders';

  @override
  String get imagePlaceholdersSubtitle => 'Choose what shows when images are missing';

  @override
  String get homeScreenSection => 'Home Screen';

  @override
  String get quickAccessSubtitle => 'Configure what appears in Quick Access';

  @override
  String get manageCoursesSubtitle => 'Add, edit, or remove courses';

  @override
  String get manageCategoriesSubtitle => 'Add, edit, or remove categories';

  @override
  String get shoppingCategoriesSubtitle => 'Organize items by aisle';

  @override
  String get syncSection => 'Sync';

  @override
  String get cloudSync => 'Cloud Sync';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get resetApp => 'Reset App';

  @override
  String get resetAppSubtitle => 'Delete all data permanently';

  @override
  String get trashSubtitle => 'Deleted recipes (30-day retention)';

  @override
  String get importRecipeTitle => 'Import Recipe';

  @override
  String get importSocialMedia => 'Import your recipes from any social media platform or website.';

  @override
  String get pasteRecipeUrl => 'Paste recipe URL';

  @override
  String get orDivider => 'OR';

  @override
  String get fileOption => 'File';

  @override
  String get imageOption => 'Image';

  @override
  String get pasteOption => 'Paste';

  @override
  String get supportedFormats => 'Supports Paprika, Mela, JSON, ZIP exports';

  @override
  String get pasteRecipeTitle => 'Paste Recipe';

  @override
  String get pasteRecipeHint => 'Paste your recipe here...';

  @override
  String get quickAccessHelpIntro => 'These badges indicate why recipes appear here:';

  @override
  String get quickAccessHelpMealPlan => 'Scheduled for today';

  @override
  String get quickAccessHelpPinned => 'You\'ve pinned this recipe';

  @override
  String get quickAccessHelpRecent => 'Recently viewed';

  @override
  String get openCalendar => 'Open calendar';

  @override
  String get editNotes => 'Edit notes';

  @override
  String get addNotesHint => 'Add notes...';

  @override
  String get moveToAnotherDay => 'Move to another day';

  @override
  String get addToPlan => 'Add to Plan';

  @override
  String importBulkQuestion(int count) {
    return 'Would you like to import all $count recipes or select individually?';
  }

  @override
  String get importingRecipes => 'Importing recipes...';

  @override
  String importedRecipesCount(int count) {
    return 'Imported $count recipes';
  }

  @override
  String get extractingArchive => 'Extracting archive...';

  @override
  String get themeSpellbook => 'Spellbook';

  @override
  String get themeForest => 'Forest';

  @override
  String get themeOcean => 'Ocean';

  @override
  String get themeSunset => 'Sunset';

  @override
  String get themeMidnight => 'Midnight';

  @override
  String get themeRose => 'Rose';

  @override
  String get colorTheme => 'Color Theme';

  @override
  String get colorThemeSubtitle => 'Choose your app\'s color palette';

  @override
  String get preview => 'Preview';

  @override
  String get previewPrimary => 'Primary';

  @override
  String get previewSecondary => 'Secondary';

  @override
  String get previewTertiary => 'Tertiary';

  @override
  String get previewError => 'Error';

  @override
  String get placeholderDescription => 'Choose what to display when recipes or cookbooks don\'t have images.';

  @override
  String get recipePlaceholders => 'Recipe Placeholders';

  @override
  String get cookbookPlaceholders => 'Cookbook Placeholders';

  @override
  String get defaultImages => 'Default Images';

  @override
  String get defaultImagesDescription => 'App artwork that changes with RPG mode';

  @override
  String get themeBased => 'Theme-based';

  @override
  String get themeBasedDescription => 'Gradient with logo based on your color theme';

  @override
  String get placeholderRpgInfo => 'Default images change between normal and RPG variants when RPG Mode is enabled.';

  @override
  String get groupBySection => 'By Section';

  @override
  String get groupByRecipe => 'By Recipe';

  @override
  String get groupByUngrouped => 'Ungrouped';

  @override
  String get copyAsText => 'Copy as Text';

  @override
  String get printList => 'Print List';

  @override
  String get manageLists => 'Manage Lists';

  @override
  String get newList => 'New';

  @override
  String get newShoppingList => 'New Shopping List';

  @override
  String get listNameHint => 'List name';

  @override
  String get recipeLayoutSetting => 'Recipe Layout';

  @override
  String get recipeLayoutSettingSubtitle => 'Choose how recipe details are displayed';

  @override
  String get layoutTabbedOption => 'Tabbed View';

  @override
  String get layoutStackedOption => 'Stacked View';

  @override
  String get nutrientsTitle => 'Nutrition';

  @override
  String get nutrientsSubtitle => 'Nutritional information per serving';

  @override
  String get addNutrients => 'Add Nutrition Info';

  @override
  String get calculateNutrients => 'Calculate from Ingredients';

  @override
  String get nutrientsDisclaimer => 'Nutritional values are estimates. Accuracy depends on ingredient measurements. Using a food scale with gram measurements provides the best accuracy.';

  @override
  String get calories => 'Calories';

  @override
  String get protein => 'Protein';

  @override
  String get carbohydrates => 'Carbs';

  @override
  String get fat => 'Fat';

  @override
  String get fiber => 'Fiber';

  @override
  String get sugar => 'Sugar';

  @override
  String get sodium => 'Sodium';

  @override
  String get cholesterol => 'Cholesterol';

  @override
  String get saturatedFat => 'Saturated Fat';

  @override
  String get transFat => 'Trans Fat';

  @override
  String get servingSize => 'Serving Size';

  @override
  String get perServing => 'Per Serving';

  @override
  String get calculatingNutrients => 'Calculating nutrition...';

  @override
  String get nutrientsCalculated => 'Nutrition calculated';

  @override
  String nutrientsFailed(String error) {
    return 'Could not calculate nutrition: $error';
  }

  @override
  String get premiumFeature => 'Premium Feature';

  @override
  String get premiumNutrientsDescription => 'Automatic nutrition calculation requires a premium subscription';

  @override
  String get exportCurrentCookbook => 'Export Current Cookbook';

  @override
  String get exporting => 'Exporting...';

  @override
  String get exportAllCookbooks => 'Export All Cookbooks';

  @override
  String get importing => 'Importing...';

  @override
  String get importFromJson => 'Import from JSON';

  @override
  String get importFromJsonSubtitle => 'Select a backup file';

  @override
  String get aboutDescription => 'Your magical recipe companion for organizing, planning, and cooking delicious meals.';

  @override
  String get madeWithLove => 'Made with ❤️ for home cooks everywhere';

  @override
  String get resetAppWarning => 'This will permanently delete all your recipes, meal plans, shopping lists, and settings. This cannot be undone.';

  @override
  String get actionContinue => 'Continue';

  @override
  String get finalConfirmation => 'Final Confirmation';

  @override
  String get typeDeleteToConfirm => 'Type DELETE to confirm';

  @override
  String get typeDeleteHint => 'DELETE';

  @override
  String get resetEverything => 'Reset Everything';

  @override
  String get resettingApp => 'Resetting app...';

  @override
  String get appResetSuccess => 'App reset successfully';

  @override
  String get resetFailed => 'Reset failed';

  @override
  String get successAdded => 'Added successfully';

  @override
  String get selectToday => 'Select Today';

  @override
  String get selectTomorrow => 'Select Tomorrow';

  @override
  String get addedManually => 'Added Manually';

  @override
  String get unknownRecipe => 'Unknown Recipe';

  @override
  String get shoppingListEmpty => 'Your shopping list is empty';

  @override
  String get shoppingListEmptyHint => 'Add items or import from recipes';

  @override
  String get settingsRPGModeActive => 'Conjuring magical text...';

  @override
  String get shoppingCheckAll => 'Check All';

  @override
  String get shoppingUncheckAll => 'Uncheck All';

  @override
  String get shoppingManageLists => 'Manage Lists';

  @override
  String get shoppingNewList => 'New Shopping List';

  @override
  String get shoppingListName => 'List name';

  @override
  String get shoppingLists => 'Shopping Lists';

  @override
  String get shoppingRenameList => 'Rename List';

  @override
  String get shoppingDeleteList => 'Delete List?';

  @override
  String get categoryProduce => 'Produce';

  @override
  String get categoryDairy => 'Dairy';

  @override
  String get categoryMeat => 'Meat';

  @override
  String get categoryBakery => 'Bakery';

  @override
  String get categoryFrozen => 'Frozen';

  @override
  String get categoryBeverages => 'Beverages';

  @override
  String get categoryPantry => 'Pantry';

  @override
  String get categorySpices => 'Spices';

  @override
  String get categoryInternational => 'International';

  @override
  String get categorySnacks => 'Snacks';

  @override
  String get categoryOther => 'Other';

  @override
  String get from => 'from';

  @override
  String get deleted => 'deleted';

  @override
  String get currently => 'Currently in';

  @override
  String get autoDetect => 'Auto-detect';

  @override
  String get category => 'Category';

  @override
  String get actionNew => 'New';

  @override
  String get actionCreate => 'Create';

  @override
  String get tagsAdd => 'Add Tag';

  @override
  String get tagsSearchOrCreate => 'Search or create tag...';

  @override
  String get tagsNoResults => 'No matching tags found';

  @override
  String get color => 'Color';

  @override
  String get icon => 'Icon';

  @override
  String get nutritionTitle => 'Nutrition';

  @override
  String get nutritionEmpty => 'No nutrition data';

  @override
  String get nutritionEmptyHint => 'Edit this recipe and calculate nutrition from ingredients';

  @override
  String get scaled => 'scaled';

  @override
  String get nutritionCalculate => 'Calculate Nutrition';

  @override
  String get nutritionCalculating => 'Calculating nutrition...';

  @override
  String get nutritionMatchingIngredients => 'Matching ingredients to USDA database';

  @override
  String get nutritionCalculationFailed => 'Could not calculate nutrition';

  @override
  String get nutritionDisclaimer => 'Nutrition values are estimates based on USDA data. Actual values may vary depending on specific products, preparation methods, and portion sizes.';

  @override
  String get nutritionPerServing => 'Per Serving';

  @override
  String nutritionServings(int count) {
    return '$count servings';
  }

  @override
  String get nutritionIngredientBreakdown => 'Ingredient Breakdown';

  @override
  String get nutritionIngredientsMatched => 'Ingredients Matched';

  @override
  String nutritionMatchedCount(int matched, int total) {
    return '$matched of $total matched';
  }

  @override
  String nutritionUncertainCount(int count) {
    return '$count need review';
  }

  @override
  String get nutritionUncertain => 'verify match';

  @override
  String get nutritionNotFound => 'No match found - tap to search';

  @override
  String get nutritionRecalculate => 'Recalculate';

  @override
  String get nutritionOverwriteTitle => 'Overwrite Nutrition Data?';

  @override
  String get nutritionOverwriteMessage => 'This recipe already has nutrition data. Do you want to recalculate and replace it with new values?';

  @override
  String get nutritionCalculated => 'Nutrition calculated successfully';

  @override
  String get nutritionSave => 'Save Nutrition';

  @override
  String get nutritionSelectFood => 'Select USDA Food';

  @override
  String get nutritionSearchFood => 'Search foods...';

  @override
  String get nutritionNoResults => 'No results found';

  @override
  String get nutritionCalories => 'Calories';

  @override
  String get nutritionProtein => 'Protein';

  @override
  String get nutritionCarbs => 'Carbohydrates';

  @override
  String get nutritionFat => 'Total Fat';

  @override
  String get nutritionSaturatedFat => 'Saturated Fat';

  @override
  String get nutritionTransFat => 'Trans Fat';

  @override
  String get nutritionFiber => 'Dietary Fiber';

  @override
  String get nutritionSugar => 'Sugars';

  @override
  String get nutritionCholesterol => 'Cholesterol';

  @override
  String get nutritionSodium => 'Sodium';

  @override
  String get nutritionPotassium => 'Potassium';

  @override
  String get nutritionCalcium => 'Calcium';

  @override
  String get nutritionIron => 'Iron';

  @override
  String get nutritionVitaminA => 'Vitamin A';

  @override
  String get nutritionVitaminC => 'Vitamin C';

  @override
  String get nutritionVitaminD => 'Vitamin D';

  @override
  String get layoutInfoText => 'Nutrition data (if calculated) will appear in both layouts. Tabbed layout allows swiping between sections.';

  @override
  String get settingsManageTagsSubtitle => 'Create and organize recipe tags';

  @override
  String get nutritionTotal => 'Total';

  @override
  String get nutritionAutoCalculate => 'Auto-Calculate';

  @override
  String get nutritionManualEntry => 'Enter Manually';

  @override
  String get nutritionManualEntryTitle => 'Enter Known Values';

  @override
  String get nutritionManualEntryDescription => 'If you know the exact nutrition values (from packaging, website, etc.), enter them here.';

  @override
  String get nutritionMainNutrients => 'Main Nutrients';

  @override
  String get nutritionOtherNutrients => 'Other Nutrients';

  @override
  String get nutritionEnterAtLeastOne => 'Enter at least calories or one macro nutrient';

  @override
  String get nutritionHowToFix => 'How to fix';

  @override
  String get nutritionHowToImproveAccuracy => 'How to Improve Accuracy';

  @override
  String get nutritionEditIngredient => 'Edit Ingredient';

  @override
  String get nutritionSearchUsda => 'Search USDA';

  @override
  String get nutritionEnterManually => 'Enter Manually';

  @override
  String get nutritionManualIngredientHint => 'Enter the nutrition values for this ingredient amount. Check the package label or a nutrition database.';

  @override
  String get nutritionApplyManual => 'Apply Manual Values';

  @override
  String get nutritionTotalRecipe => 'Total Recipe Nutrition';

  @override
  String get nutritionMatchRate => 'Match Rate';

  @override
  String get allergySettingsTitle => 'Allergy Settings';

  @override
  String get allergyInfoText => 'Select your allergens below. Recipe Spellbook will warn you when recipes contain ingredients you\'re allergic to.';

  @override
  String allergySelectedCount(int count) {
    return '$count allergens selected';
  }

  @override
  String get allergySelectAll => 'Select All';

  @override
  String get allergyClearAll => 'Clear All';

  @override
  String get allergyMajorTitle => 'Major Allergens';

  @override
  String get allergyMajorSubtitle => 'FDA-recognized major food allergens';

  @override
  String get allergyAdditionalTitle => 'Additional Allergens';

  @override
  String get allergyAdditionalSubtitle => 'Other common food sensitivities';

  @override
  String get allergyWillWarn => 'You\'ll be warned about this allergen';

  @override
  String get allergyWarningTitle => '⚠️ Allergy Warning';

  @override
  String get allergyWarningTitlePossible => '⚠️ Possible Allergens';

  @override
  String get allergyContains => 'Contains:';

  @override
  String get allergyMayContain => 'May contain:';

  @override
  String get allergyContainsAllergens => 'Contains allergens';

  @override
  String get allergyManageSettings => 'Manage allergy settings';

  @override
  String get allergyDetailsTitle => 'Allergen Details';

  @override
  String get settingsAllergies => 'Allergies';

  @override
  String get settingsAllergiesSubtitle => 'Set up allergen warnings';

  @override
  String get allergenMilk => 'Milk/Dairy';

  @override
  String get allergenEggs => 'Eggs';

  @override
  String get allergenFish => 'Fish';

  @override
  String get allergenShellfish => 'Shellfish';

  @override
  String get allergenTreeNuts => 'Tree Nuts';

  @override
  String get allergenPeanuts => 'Peanuts';

  @override
  String get allergenWheat => 'Wheat/Gluten';

  @override
  String get allergenSoy => 'Soy';

  @override
  String get allergenSesame => 'Sesame';

  @override
  String get allergenMustard => 'Mustard';

  @override
  String get allergenCelery => 'Celery';

  @override
  String get allergenLupin => 'Lupin';

  @override
  String get allergenMollusks => 'Mollusks';

  @override
  String get allergenSulfites => 'Sulfites';

  @override
  String get allergenCorn => 'Corn';

  @override
  String get allergenNightshades => 'Nightshades';

  @override
  String get nutritionCopyFromAuto => 'Copy from Auto-Calculate';

  @override
  String get nutritionEstimatedDisclaimer => 'Values are estimated based on USDA data';

  @override
  String get actionDiscard => 'Discard';

  @override
  String get unsavedChangesTitle => 'Unsaved Changes';

  @override
  String get unsavedChangesMessage => 'You have unsaved changes. Do you want to save them?';

  @override
  String get tagsEmptyTitle => 'No Tags Yet';

  @override
  String get tagsEmptySubtitle => 'Create tags to organize your recipes by dietary needs, meal type, and more.';

  @override
  String get tagsLoadDefaults => 'Load Default Tags';

  @override
  String get tagsAddNew => 'Add Tag';

  @override
  String get tagsEdit => 'Edit Tag';

  @override
  String get tagsDelete => 'Delete Tag';

  @override
  String tagsDeleteConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get tagsNameLabel => 'Tag Name';

  @override
  String get tagsIconLabel => 'Icon (emoji)';

  @override
  String get tagsColorLabel => 'Color';

  @override
  String get settingsRpgAnimations => 'Rarity Animations';

  @override
  String get settingsRpgAnimationsSubtitle => 'Glowing effects for epic and legendary recipes';

  @override
  String get settingsRpgSounds => 'Sound Effects';

  @override
  String get settingsRpgSoundsSubtitle => 'Play sounds for achievements and level ups';

  @override
  String get settingsRpgAchievements => 'Achievements';

  @override
  String get settingsRpgAchievementsSubtitle => 'View your unlocked achievements';

  @override
  String get settingsRpgStats => 'Cooking Stats';

  @override
  String get settingsRpgStatsSubtitle => 'View your cooking statistics';

  @override
  String get settingsRpgModeEnabled => 'Transform your cooking into an adventure!';

  @override
  String get settingsRecipeLayoutSubtitle => 'Customize how recipes are displayed';

  @override
  String get rarityCommon => 'Common';

  @override
  String get rarityCommonDesc => 'A simple everyday recipe';

  @override
  String get rarityUncommon => 'Uncommon';

  @override
  String get rarityUncommonDesc => 'A tasty recipe with a twist';

  @override
  String get rarityRare => 'Rare';

  @override
  String get rarityRareDesc => 'A special recipe worth mastering';

  @override
  String get rarityEpic => 'Epic';

  @override
  String get rarityEpicDesc => 'An epic recipe of great power!';

  @override
  String get rarityLegendary => 'Legendary';

  @override
  String get rarityLegendaryDesc => 'A legendary recipe worthy of the gods!';

  @override
  String get shareLink => 'Link';

  @override
  String get shareDocument => 'PDF';

  @override
  String get sharePrint => 'Print';

  @override
  String get shareLinkDescription => 'Share a link that others can use to view this recipe.';

  @override
  String get shareLinkNote => 'Recipients need the Recipe Spellbook app or can view on web.';

  @override
  String get shareCreatingDocument => 'Creating document...';

  @override
  String get editLayoutTitle => 'Edit Layout';

  @override
  String get editLayoutStacked => 'Stacked';

  @override
  String get editLayoutTabbed => 'Tabbed';

  @override
  String get editLayoutStackedDesc => 'All sections in one scrollable view';

  @override
  String get editLayoutTabbedDesc => 'Separate tabs for details, ingredients, instructions';

  @override
  String get tabDetails => 'Details';

  @override
  String get tabIngredients => 'Ingredients';

  @override
  String get tabInstructions => 'Instructions';

  @override
  String get stepImageAdd => 'Add Image';

  @override
  String get stepImageChange => 'Change Image';

  @override
  String get stepImageRemove => 'Remove Image';

  @override
  String get stepTimer => 'Timer';

  @override
  String stepTimerMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get recipeAddToCookbook => 'Add to Cookbook';

  @override
  String get recipeMoveToTrash => 'Move to Trash';

  @override
  String get tagsEmpty => 'No tags';

  @override
  String get nutritionPerServingLabel => 'Per Serving';

  @override
  String get nutritionTotalLabel => 'Total Recipe';

  @override
  String get trendingRecipes => 'Trending recipes';

  @override
  String get addShortcut => 'Add the Recipe Spellbook shortcut';

  @override
  String get addShortcutSubtitle => 'Import recipes with one tap';

  @override
  String get importGuides => 'Read our import guides';

  @override
  String get useOnDesktop => 'Use Recipe Spellbook on desktop';

  @override
  String get inviteFriends => 'Invite friends';

  @override
  String get inviteFriendsTitle => 'Share Recipe Spellbook';

  @override
  String get inviteFriendsSubtitle => 'Invite your friends and family to start cooking together!';

  @override
  String get shareApp => 'Share App';

  @override
  String get maybeLater => 'Maybe later';

  @override
  String get createAccount => 'Create account';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get premiumSubtitle => 'Unlock sync, unlimited recipes & more';

  @override
  String get rpgMode => 'RPG Mode';

  @override
  String get leaderboards => 'Leaderboards';

  @override
  String get achievements => 'Achievements';

  @override
  String get cookingStats => 'Cooking Stats';

  @override
  String get stepByStepGuides => 'Step-by-step guides';

  @override
  String get importGuidesSubtitle => 'Learn how to import recipes from your favorite apps and websites';

  @override
  String get importFromOtherApps => 'Import from other apps';

  @override
  String get orderOnline => 'Order online';

  @override
  String get helpTitle => 'Help';

  @override
  String get navMenu => 'Menu';

  @override
  String get mealPlanTitle => 'My Meal Plan';

  @override
  String get noRecipesYet => 'No recipes yet';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get snack => 'Snack';

  @override
  String get allergenGluten => 'Gluten';

  @override
  String get allergenChocolate => 'Chocolate & Cocoa';

  @override
  String get allergenCaffeine => 'Caffeine';

  @override
  String get allergenAlcohol => 'Alcohol';

  @override
  String get allergenCitrus => 'Citrus';

  @override
  String get allergenStoneFruits => 'Stone Fruits';

  @override
  String get allergenCoconut => 'Coconut';

  @override
  String get allergenGarlic => 'Garlic';

  @override
  String get allergenOnion => 'Onion';

  @override
  String get allergenMushrooms => 'Mushrooms';

  @override
  String get allergenAvocado => 'Avocado';

  @override
  String get allergenBanana => 'Banana';

  @override
  String get allergenKiwi => 'Kiwi';

  @override
  String get allergenLatexFoods => 'Latex Cross-Reactive';

  @override
  String get allergenFodmap => 'High FODMAP';

  @override
  String get allergenHistamine => 'High Histamine';

  @override
  String get allergenSalicylates => 'Salicylates';

  @override
  String get allergenMsg => 'MSG';

  @override
  String get allergenRedMeat => 'Red Meat (Alpha-gal)';

  @override
  String get allergenGelatin => 'Gelatin';

  @override
  String get allergyWarningContains => 'May contain:';

  @override
  String get allergyDismissForRecipe => 'Dismiss for this recipe';

  @override
  String get allergyDismissUndo => 'Undo';

  @override
  String get allergyWarningDismissed => 'Warning dismissed for this recipe';

  @override
  String get scaleCustom => 'Custom';

  @override
  String get scaleCustomTitle => 'Custom Scale';

  @override
  String get scaleCustomHint => 'Enter any number (e.g., 0.75 for 3/4, 2.5 for 2½)';

  @override
  String get scaleApply => 'Apply';

  @override
  String get addStep => 'Add step';

  @override
  String get noInstructionsYet => 'No instructions yet';

  @override
  String get addFirstStep => 'Add first step';

  @override
  String get enterInstruction => 'Enter instruction...';

  @override
  String get addStepImage => 'Add step image';

  @override
  String get removeStep => 'Remove step';

  @override
  String get plannerNoMeals => 'No meals planned';

  @override
  String get plannerAddMealHint => 'Tap + to add a meal for this day';

  @override
  String plannerMealAdded(String recipe, String mealType) {
    return '$recipe added to $mealType';
  }

  @override
  String get plannerShareMealPlan => 'Share meal plan';

  @override
  String get plannerAddWeekToShopping => 'Add week to shopping list';

  @override
  String get plannerClearWeek => 'Clear this week';

  @override
  String get plannerClearWeekConfirm => 'This will remove all meals planned for this week. This cannot be undone.';

  @override
  String get plannerWeekCleared => 'Week cleared';

  @override
  String get plannerGoToToday => 'Go to today';

  @override
  String get plannerAddAnother => 'Add another meal';

  @override
  String get plannerSearchRecipes => 'Search recipes...';

  @override
  String get mealTypeBreakfast => 'Breakfast';

  @override
  String get mealTypeLunch => 'Lunch';

  @override
  String get mealTypeDinner => 'Dinner';

  @override
  String get mealTypeSnack => 'Snack';

  @override
  String shoppingItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'items',
      one: 'item',
    );
    return '$count $_temp0';
  }

  @override
  String get shoppingBySection => 'By Section';

  @override
  String get shoppingByRecipe => 'By Recipe';

  @override
  String get shoppingUngrouped => 'Ungrouped';

  @override
  String get shoppingOrderOnline => 'Order online';

  @override
  String get shoppingEditItem => 'Edit Item';

  @override
  String get shoppingItemName => 'Item name';

  @override
  String get shoppingSelectCategory => 'Select category';

  @override
  String get shoppingAddedManually => 'Added manually';

  @override
  String get shoppingEmptyList => 'Your list is empty';

  @override
  String get shoppingEmptyHint => 'Tap + to add items or add ingredients from your recipes';

  @override
  String get shoppingAddHint => 'Press Enter or tap send to add, then type the next item';

  @override
  String get categoryDeli => 'Deli';

  @override
  String get categoryBreakfast => 'Breakfast & Cereal';

  @override
  String get categoryCanned => 'Canned Goods & Soups';

  @override
  String get categoryCondiments => 'Condiments, Sauces & Spices';

  @override
  String get categoryAlcohol => 'Beer, Wine & Spirits';

  @override
  String get categoryBaby => 'Baby';

  @override
  String get categoryBeauty => 'Beauty & Personal Care';

  @override
  String get categoryHousehold => 'Housewares';

  @override
  String get categoryPet => 'Pet';

  @override
  String importFromPlatform(String platform) {
    return 'Import from $platform';
  }

  @override
  String importFromApp(String app) {
    return 'Import from $app';
  }

  @override
  String get helpAddingRecipes => 'Adding Recipes';

  @override
  String get helpAddingRecipesDesc => 'Tap the + button in any cookbook to add a recipe. You can import from URLs, take photos, or enter manually.';

  @override
  String get helpImporting => 'Importing from Apps';

  @override
  String get helpImportingDesc => 'Share a recipe from Instagram, TikTok, or any website directly to Recipe Spellbook.';

  @override
  String get helpMealPlanning => 'Meal Planning';

  @override
  String get helpMealPlanningDesc => 'Tap the Meal Plan tab to plan your meals for the week. Tap + on any day to add recipes.';

  @override
  String get helpShopping => 'Shopping Lists';

  @override
  String get helpShoppingDesc => 'Add ingredients from recipes to your shopping list. Items are organized by store section.';

  @override
  String get helpSyncing => 'Syncing';

  @override
  String get helpSyncingDesc => 'Cloud sync is coming soon! Your recipes will sync across all your devices.';

  @override
  String get helpContactUs => 'Contact Us';

  @override
  String get helpContactUsDesc => 'Have questions or feedback? Email us at support@recipespellbook.com';

  @override
  String get navCommunity => 'Community';

  @override
  String get navComingSoon => 'Coming soon';

  @override
  String get mealPlanButton => 'Meal Plan';

  @override
  String get groceriesButton => 'Groceries';

  @override
  String get shareButton => 'Share';

  @override
  String get scaleRecipeButton => 'Scale';

  @override
  String get convertUnitsButton => 'Convert';

  @override
  String get allergyDismissTooltip => 'Dismiss warning';

  @override
  String get allergyDisablePrompt => 'Disable this warning permanently for this recipe?';

  @override
  String get allergyDisabledForRecipe => 'Warning disabled for this recipe';

  @override
  String get allergyRestoreWarnings => 'Restore warnings';

  @override
  String get recipeDuplicated => 'Recipe duplicated';

  @override
  String get recipeDeleted => 'Recipe moved to trash';

  @override
  String get deleteRecipeTitle => 'Delete Recipe';

  @override
  String get deleteRecipeConfirm => 'Are you sure you want to delete this recipe? It will be moved to trash.';

  @override
  String get addToShoppingListTitle => 'Add to Shopping List';

  @override
  String get viewList => 'View List';

  @override
  String get selectItems => 'Select items';

  @override
  String addToListCount(int count) {
    return 'Add $count items';
  }

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get restore => 'Restore';

  @override
  String get unselectAll => 'Unselect All';

  @override
  String get deleteStep => 'Delete Step';

  @override
  String get deleteSteps => 'Delete Steps';

  @override
  String get deleteStepConfirm => 'Delete this step?';

  @override
  String deleteStepsConfirm(int count) {
    return 'Delete $count steps?';
  }

  @override
  String stepSelected(int count) {
    return '$count selected';
  }

  @override
  String get selectAllSteps => 'Select All';

  @override
  String get gradientBased => 'Gradient-Based';

  @override
  String get gradientBasedDescription => 'Color gradient based on your theme';

  @override
  String get startCooking => 'Start Cooking';

  @override
  String get fontSizeLabel => 'Font Size';

  @override
  String krogerLoginDenied(String error) {
    return 'Kroger login was denied: $error';
  }

  @override
  String get krogerNoAuthCode => 'No authorization code received from Kroger.';

  @override
  String get krogerConnected => 'Kroger connected! You can now send items directly to your cart.';

  @override
  String get krogerConnectFailed => 'Failed to connect Kroger. Please try again.';

  @override
  String get krogerConnecting => 'Connecting to Kroger…';

  @override
  String get krogerExchanging => 'Exchanging authorization...';

  @override
  String get krogerConnectedTitle => 'Connected!';

  @override
  String get krogerConnectionFailed => 'Connection Failed';

  @override
  String get goToShoppingList => 'Go to Shopping List';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get skipDuplicates => 'Skip dupes';

  @override
  String get deselectAll => 'Deselect all';

  @override
  String get duplicate => 'Duplicate';

  @override
  String recipesImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recipes',
      one: 'recipe',
    );
    return '$count $_temp0 imported';
  }

  @override
  String importCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recipes',
      one: 'recipe',
    );
    return 'Import $count $_temp0';
  }

  @override
  String get productNotFound => 'Product Not Found';

  @override
  String barcodeNotFound(String barcode) {
    return 'No product found for barcode:\n$barcode';
  }

  @override
  String get manualEntryHint => 'You can manually enter the product name.';

  @override
  String get scanAgain => 'Scan Again';

  @override
  String get enterManually => 'Enter Manually';

  @override
  String get enterProductName => 'Enter Product Name';

  @override
  String get productName => 'Product name';

  @override
  String get scanBarcode => 'Scan Barcode';

  @override
  String get lookingUpProduct => 'Looking up product...';

  @override
  String get pointCameraBarcode => 'Point your camera at a product barcode';

  @override
  String get unknownProduct => 'Unknown Product';

  @override
  String get nutritionPer100g => 'Nutrition (per 100g)';

  @override
  String get findRecipesWithThis => 'Find Recipes with This';

  @override
  String get scanAnother => 'Scan Another';

  @override
  String get exportFormat => 'Export Format';

  @override
  String get gotIt => 'Got it';

  @override
  String get calendar => 'Calendar';

  @override
  String get today => 'Today';

  @override
  String get shareMealPlan => 'Share meal plan';

  @override
  String get addWeekToShoppingList => 'Add week to shopping list';

  @override
  String get clearThisWeek => 'Clear this week?';

  @override
  String get clearWeekWarning => 'This will remove all meals planned for this week. This cannot be undone.';

  @override
  String get goToToday => 'Go to today';

  @override
  String get addAnotherMeal => 'Add another meal';

  @override
  String get meal => 'Meal';

  @override
  String get noMealsPlanned => 'No meals planned';

  @override
  String get tapToAddMeal => 'Tap + to add a meal for this day';

  @override
  String get addMeal => 'Add meal';

  @override
  String addToDay(String dayName) {
    return 'Add to $dayName';
  }

  @override
  String get searchRecipes => 'Search recipes...';

  @override
  String get noRecipesFound => 'No recipes found';

  @override
  String get exitShoppingListGenerator => 'Exit Shopping List Generator?';

  @override
  String get actionExit => 'Exit';

  @override
  String get shoppingListGenerator => 'Shopping List Generator';

  @override
  String reviewAndAdd(int count) {
    return 'Review & Add ($count items)';
  }

  @override
  String addItemsToList(int count) {
    return 'Add $count items to list';
  }

  @override
  String addedItemsToShoppingList(int count) {
    return 'Added $count items to shopping list';
  }

  @override
  String get createNewList => 'Create new list';

  @override
  String get listName => 'List name';

  @override
  String get manage => 'Manage';

  @override
  String get myPantry => 'My Pantry';

  @override
  String get itemsAlwaysOnHand => 'Items you always have on hand';

  @override
  String get whatToDelete => 'What would you like to delete?';

  @override
  String get localData => 'Local Data';

  @override
  String get localDataDesc => 'Recipes, cookbooks, meal plans, shopping lists on this device';

  @override
  String get cloudData => 'Cloud Data';

  @override
  String get cloudDataDesc => 'Coming soon — Cloud Sync not yet available';

  @override
  String get allData => 'All Data';

  @override
  String get allDataDesc => 'Local data and settings — complete fresh start';

  @override
  String permanentDeleteWarning(String scope) {
    return 'This will permanently delete $scope. This cannot be undone.';
  }

  @override
  String get dataResetComplete => 'Data Reset Complete';

  @override
  String get noThanks => 'No thanks';

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get yesAddThem => 'Yes, add them';

  @override
  String get nutritionDisplay => 'Nutrition Display';

  @override
  String get nutritionDisplaySubtitle => 'Chart style, visible nutrients';

  @override
  String get storeIntegrations => 'Store Integrations';

  @override
  String get instacart => 'Instacart';

  @override
  String get kroger => 'Kroger';

  @override
  String get connected => 'Connected';

  @override
  String get setCustomApiKey => 'Set custom API key';

  @override
  String get useOwnInstacartKey => 'Use your own Instacart Connect key';

  @override
  String get instacartApiKey => 'Instacart API Key';

  @override
  String get resetToDefaultKey => 'Reset to default key';

  @override
  String get removeCustomKey => 'Remove custom key, use built-in';

  @override
  String get signInToKroger => 'Sign in to Kroger';

  @override
  String get connectToAddItems => 'Connect to add items to your cart';

  @override
  String get setPreferredStore => 'Set preferred store';

  @override
  String get searchByZipCode => 'Search by zip code';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get apiKeySaved => 'API key saved';

  @override
  String get findYourKrogerStore => 'Find your Kroger store';

  @override
  String get enterZipCode => 'Enter zip code';

  @override
  String storeSet(String name) {
    return 'Store set: $name';
  }

  @override
  String get menuImportSubtitle => 'Instagram, TikTok, websites...';

  @override
  String get menuSyncToMobile => 'Sync to mobile';

  @override
  String get menuSyncToDesktop => 'Sync to desktop';

  @override
  String get menuTransferToPhone => 'Transfer data to your phone';

  @override
  String get menuTransferToDevice => 'Transfer data to another device';

  @override
  String get menuProfile => 'Profile';

  @override
  String get menuProfileSubtitle => 'View your stats and progress';

  @override
  String get menuAchievementsSubtitle => 'Unlock rewards';

  @override
  String get menuCosmetics => 'Cosmetics';

  @override
  String get menuCosmeticsSubtitle => 'Customize your look';

  @override
  String get menuLeaderboardsSubtitle => 'Compete with others';

  @override
  String get menuBossBattles => 'Boss Battles';

  @override
  String get menuBossBattlesSubtitle => 'Epic cooking challenges';

  @override
  String get menuImportRecipes => 'Import Recipes';

  @override
  String get menuHelpSupport => 'Help & Support';

  @override
  String menuAppVersion(String version) {
    return 'Recipe Spellbook v$version';
  }

  @override
  String get menuShareApp => 'Share Recipe Spellbook';

  @override
  String get menuShareSubtitle => 'Invite your friends and family to start cooking together!';

  @override
  String get menuShareMessage => 'Check out Recipe Spellbook - the best recipe app! https://recipespellbook.app';

  @override
  String get signIn => 'Sign in';

  @override
  String get helpFromWebsite => 'From a website';

  @override
  String get helpFromWebsiteDesc => 'Tap + in any cookbook, then paste a recipe URL. Works with most recipe sites including AllRecipes, Food Network, NYT Cooking, and thousands more.';

  @override
  String get helpFromSocial => 'From Instagram or TikTok';

  @override
  String get helpFromSocialDesc => 'Copy the link to a recipe post, then tap + and paste it. Recipe Spellbook will extract the recipe from the page.';

  @override
  String get helpFromPhoto => 'From a photo';

  @override
  String get helpFromPhotoDesc => 'Take a photo of a recipe in a cookbook or magazine. Tap + then choose Image to scan it with OCR.';

  @override
  String get helpFromPdf => 'From a PDF';

  @override
  String get helpFromPdfDesc => 'Tap + then choose File to import a PDF recipe. The text will be extracted automatically.';

  @override
  String get helpFromText => 'From text';

  @override
  String get helpFromTextDesc => 'Copy recipe text from anywhere, tap + then Paste. Recipe Spellbook will detect ingredients and instructions.';

  @override
  String get helpFromPaprika => 'From Paprika';

  @override
  String get helpFromPaprikaDesc => 'In Paprika, go to Export and choose \"HTML\" format. Then tap + in Recipe Spellbook and import the HTML file.';

  @override
  String get helpFromOtherApps => 'From other apps';

  @override
  String get helpFromOtherAppsDesc => 'Most recipe apps can export as HTML or text. Export from your old app, then import the file here using the + button.';

  @override
  String get helpCloudSync => 'Cloud Sync';

  @override
  String get helpCloudSyncDesc => 'Subscribe to Cloud Sync to keep your recipes in sync across all your devices. Tap the sync button in the sidebar to sync manually.';

  @override
  String get accountTitle => 'Account';

  @override
  String get signInToSync => 'Sign in to sync recipes';

  @override
  String get signInSyncDesc => 'Back up your recipes, sync across devices, and unlock premium features.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutQuestion => 'Sign out?';

  @override
  String get signOutDesc => 'Your recipes stay on this device. You can sign back in anytime to re-enable sync.';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountQuestion => 'Delete account?';

  @override
  String get deleteAccountDesc => 'This permanently deletes your account and all synced data from our servers.\n\nRecipes stored locally on this device will NOT be deleted.';

  @override
  String get deletePermanently => 'Delete permanently';

  @override
  String get deleteAccountFailed => 'Failed to delete account. Please try again.';

  @override
  String get signInToApp => 'Sign in to Recipe Spellbook';

  @override
  String get signInSyncLong => 'Sync your recipes across devices, unlock cloud backup, and access Pro features.';

  @override
  String get recipesStayOnDevice => 'Your recipes stay on this device even without an account.';

  @override
  String get upgradeToPro => 'Upgrade to Pro';

  @override
  String subscriptionDot(String tier) {
    return 'Subscription · $tier';
  }

  @override
  String get affluentLabsPro => 'Affluent Labs Pro';

  @override
  String cancelledAccessUntil(String date) {
    return 'Cancelled — access until $date';
  }

  @override
  String get lifetimeNeverExpires => 'Lifetime — never expires';

  @override
  String renewsDate(String date) {
    return 'Renews $date';
  }

  @override
  String get manageSubscription => 'Manage Subscription';

  @override
  String get tierPremium => 'Premium';

  @override
  String get tierStandard => 'Standard';

  @override
  String get tierBasic => 'Basic';

  @override
  String get tierFree => 'Free';

  @override
  String tierPlan(String tier) {
    return '$tier Plan';
  }

  @override
  String get upgradeArrow => 'Upgrade →';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get syncing => 'Syncing...';

  @override
  String lastSynced(String time) {
    return 'Last synced $time';
  }

  @override
  String get notYetSynced => 'Not yet synced';

  @override
  String get cloudSyncSection => 'CLOUD SYNC';

  @override
  String get noRecipesPlannedThisWeek => 'No recipes planned this week';

  @override
  String get todayBadge => 'TODAY';

  @override
  String get noCourseAssigned => 'No Course Assigned';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get allRecipesHaveCourse => 'All recipes have a course!';

  @override
  String get allRecipesCategorized => 'All recipes are categorized!';

  @override
  String get greatJobOrganizing => 'Great job organizing your recipes.';

  @override
  String countOfTotal(int count, int total) {
    return '$count of $total';
  }

  @override
  String get tapToAssignCourse => 'Tap to assign a course';

  @override
  String get tapToAssignCategory => 'Tap to assign a category';

  @override
  String deleteCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recipes',
      one: 'recipe',
    );
    return 'Delete $count $_temp0?';
  }

  @override
  String countRecipesMovedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recipes',
      one: 'recipe',
    );
    return '$count $_temp0 moved to trash';
  }

  @override
  String get setCourse => 'Set Course';

  @override
  String get setCategory => 'Set Category';

  @override
  String courseSetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recipes',
      one: 'recipe',
    );
    return 'Course set for $count $_temp0';
  }

  @override
  String categorySetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recipes',
      one: 'recipe',
    );
    return 'Category set for $count $_temp0';
  }

  @override
  String countRecipesFavorited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recipes',
      one: 'recipe',
    );
    return '$count $_temp0 favorited';
  }

  @override
  String get bulkCourse => 'Course';

  @override
  String get bulkCategory => 'Category';

  @override
  String get bulkFavorite => 'Favorite';

  @override
  String get aiImportTitle => 'Import from AI';

  @override
  String get aiCopyPrompt => 'Copy the prompt';

  @override
  String get aiCopyPromptSubtitle => 'Paste this into ChatGPT, Claude, Gemini, or any AI along with your recipe.';

  @override
  String get aiCopied => 'Copied!';

  @override
  String get aiCopyToClipboard => 'Copy Prompt to Clipboard';

  @override
  String get aiPreviewPrompt => 'Preview prompt';

  @override
  String get aiPasteOutput => 'Paste the AI output';

  @override
  String get aiPasteSubtitle => 'Paste the JSON the AI gave you, or import a .json file.';

  @override
  String get aiPasteFirst => 'Paste or load JSON first.';

  @override
  String aiFailedReadFile(String error) {
    return 'Failed to read file: $error';
  }

  @override
  String get aiUntitledRecipe => 'Untitled Recipe';

  @override
  String get aiImporting => 'Importing...';

  @override
  String get aiImportToCookbook => 'Import to Cookbook';

  @override
  String get aiImportSuccess => 'Recipe imported successfully!';

  @override
  String get aiPreviewImport => 'Preview & Import';

  @override
  String get aiPromptCopied => 'Prompt copied! Paste it into any AI with your recipe.';

  @override
  String get aiLoadJsonFile => 'Load .json file';

  @override
  String get aiPaste => 'Paste';

  @override
  String get aiTipsTitle => 'Tips';

  @override
  String get aiTip1 => 'Works with ChatGPT, Claude, Gemini, Copilot, or any AI';

  @override
  String get aiTip2 => 'You can also take a photo of a recipe and paste it with the prompt';

  @override
  String get aiTip3 => 'The AI will convert handwritten, printed, or web recipes';

  @override
  String get aiTip4 => 'If the JSON has errors, try telling the AI to fix it';

  @override
  String aiServingsLabel(String count) {
    return '$count servings';
  }

  @override
  String aiPrepLabel(String minutes) {
    return '${minutes}m prep';
  }

  @override
  String aiCookLabel(String minutes) {
    return '${minutes}m cook';
  }

  @override
  String aiIngredientsCount(int count) {
    return 'Ingredients ($count)';
  }

  @override
  String aiStepsCount(int count) {
    return 'Steps ($count)';
  }

  @override
  String get restoreAllWarnings => 'Restore All Warnings';

  @override
  String get warningsRestoredForRecipe => 'Warnings restored for recipe';

  @override
  String get restoreAllWarningsQuestion => 'Restore All Warnings?';

  @override
  String get restoreAll => 'Restore All';

  @override
  String get allWarningsRestored => 'All warnings restored';

  @override
  String dismissedWarnings(int count) {
    return '$count dismissed';
  }

  @override
  String get restoringPurchases => 'Restoring purchases...';

  @override
  String get restorePurchases => 'Restore';

  @override
  String get compareAllPlans => 'Compare all plans';

  @override
  String get oneTimeTab => 'One-Time';

  @override
  String get subscriptionTab => 'Subscription';

  @override
  String get payOnceKeepForever => 'Pay once, keep forever';

  @override
  String get cloudSyncFeature => 'Cloud Sync';

  @override
  String get cloudSyncPlusFeature => 'Cloud Sync+';

  @override
  String get unableToLoadProducts => 'Unable to load products. Try again.';

  @override
  String get noOfferingsAvailable => 'No offerings available. Try again later.';

  @override
  String purchaseFailed(String error) {
    return 'Purchase failed: $error';
  }

  @override
  String get hintProductExample => 'e.g., Organic Pasta Sauce';

  @override
  String get previewPhoto => 'Preview Photo';

  @override
  String get retake => 'Retake';

  @override
  String get usePhoto => 'Use Photo';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get removeImage => 'Remove image';

  @override
  String get tipsPlaceholder => 'Tips, variations, storage instructions...';

  @override
  String get totalCalories => 'Total cal';

  @override
  String get caloriesPerServing => 'Cal/serving';

  @override
  String get totalNutrition => 'Total';

  @override
  String get linkRecipe => 'Link Recipe';

  @override
  String get addIngredient => 'Add Ingredient';

  @override
  String get searchRecipesToLink => 'Search recipes to link...';

  @override
  String linkToIngredient(String name) {
    return 'Link to \"$name\"';
  }

  @override
  String errorSavingRecipe(String error) {
    return 'Error saving recipe: $error';
  }

  @override
  String deleteSelectedCount(int count) {
    return 'Delete $count';
  }

  @override
  String get takeAPhoto => 'Take a photo';

  @override
  String get defaultLabel => 'Default';

  @override
  String get scaleRecipe => 'Scale Recipe';

  @override
  String get scaleHint => 'e.g., 2.5';

  @override
  String get badgePinned => 'Pinned';

  @override
  String get badgeRecentlyViewed => 'Recently Viewed';

  @override
  String get displayOptions => 'Display Options';

  @override
  String get showMealPlan => 'Show Meal Plan';

  @override
  String get showMealPlanSubtitle => 'Display today\'s scheduled recipes';

  @override
  String get showPinnedRecipes => 'Show Pinned Recipes';

  @override
  String get showPinnedSubtitle => 'Display recipes you\'ve pinned';

  @override
  String get showRecentHistory => 'Show Recent History';

  @override
  String get showRecentSubtitle => 'Display recently viewed recipes';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get measurementsUS => 'cups, tablespoons, ounces, °F';

  @override
  String get measurementsMetric => 'milliliters, grams, °C';

  @override
  String defaultRecipesImported(int count) {
    return '$count default recipes imported!';
  }

  @override
  String get shoppingListGeneratorTitle => 'Shopping List Generator';

  @override
  String get exitShoppingListGeneratorQuestion => 'Exit Shopping List Generator?';

  @override
  String reviewAndAddItems(int count) {
    return 'Review & Add ($count items)';
  }

  @override
  String addedTotalItemsToList(int count) {
    return 'Added $count items to shopping list';
  }

  @override
  String scaleMultiplier(String scale) {
    return '${scale}x';
  }

  @override
  String get printIngredients => 'Ingredients';

  @override
  String get printInstructions => 'Instructions';

  @override
  String get printNotes => 'Notes';

  @override
  String printPrep(int minutes) {
    return 'Prep: $minutes min';
  }

  @override
  String printCook(int minutes) {
    return 'Cook: $minutes min';
  }

  @override
  String get printFooter => 'Printed from Recipe Spellbook';

  @override
  String printPage(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get menuNavigation => 'NAVIGATION';

  @override
  String get menuImport => 'IMPORT';

  @override
  String get menuRpgMode => 'RPG MODE';

  @override
  String get menuSocial => 'SOCIAL';

  @override
  String get menuApp => 'APP';

  @override
  String get historyCount => 'History Count';

  @override
  String get historyCountSubtitle => 'Maximum number of recent recipes to show';

  @override
  String get restoreAllWarningsDesc => 'This will re-enable allergy warnings for all recipes. You will start seeing warnings again when viewing these recipes.';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get signInForPurchaseDesc => 'An account is required before purchasing so your subscription stays linked across devices.';

  @override
  String get menuAchievements => 'Achievements';

  @override
  String get menuLeaderboards => 'Leaderboards';

  @override
  String get requiresPremium => 'Requires Premium';

  @override
  String deleteCount(int count) {
    return 'Delete $count';
  }

  @override
  String get tapToSelectPhoto => 'Tap to select from gallery or camera';

  @override
  String get rating => 'Rating';

  @override
  String get usUnits => 'cups, tablespoons, ounces, °F';

  @override
  String get metricUnits => 'milliliters, grams, °C';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String deleteRecipesConfirm(int count) {
    return 'Delete $count recipe(s)?';
  }

  @override
  String courseSetForRecipes(int count) {
    return 'Course set for $count recipe(s)';
  }

  @override
  String get recipeImportedSuccess => 'Recipe imported successfully!';

  @override
  String get promptCopied => 'Prompt copied! Paste it into any AI with your recipe.';

  @override
  String get importFromAI => 'Import from AI';

  @override
  String get paste => 'Paste';

  @override
  String get previewAndImport => 'Preview & Import';

  @override
  String get signInDescription => 'Back up your recipes, sync across devices, and unlock premium features.';

  @override
  String get signOutConfirmTitle => 'Sign out?';

  @override
  String get signOutConfirmMessage => 'Your recipes stay on this device. You can sign back in anytime to re-enable sync.';

  @override
  String get deleteAccountConfirmTitle => 'Delete account?';

  @override
  String get deleteAccountConfirmMessage => 'This permanently deletes your account and all synced data from our servers.\n\nRecipes stored locally on this device will NOT be deleted.';

  @override
  String planLabel(String label) {
    return '$label Plan';
  }

  @override
  String permanentlyDeleteWarning(String scope) {
    return 'This will permanently delete $scope. This cannot be undone.';
  }

  @override
  String recipesMovedToTrash(int count) {
    return '$count recipe(s) moved to trash';
  }

  @override
  String recipesFavorited(int count) {
    return '$count recipe(s) favorited';
  }

  @override
  String get upgradeRecipeSpellbook => 'Upgrade Recipe Spellbook';

  @override
  String get choosePlanSubtitle => 'Choose the plan that fits your kitchen';

  @override
  String get premiumInfoNotice => 'Premium is a one-time purchase that enhances your free experience. It does not include family sharing or advanced cloud features — see Subscriptions for those.';

  @override
  String get bestValue => 'BEST VALUE';

  @override
  String get billedMonthly => 'Billed monthly';

  @override
  String get save16Yearly => 'Save 16% — only \$2.50/mo';

  @override
  String get save16Badge => 'SAVE 16%';

  @override
  String get save17Yearly => 'Save 17% — only \$4.17/mo';

  @override
  String get subscriptionsIncludePremium => 'All subscriptions include everything in Premium.';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get purchasePremiumCta => 'Purchase Premium — \$6.99';

  @override
  String get subscribeCloudSyncMonthlyCta => 'Subscribe — \$2.99/mo';

  @override
  String get subscribeCloudSyncYearlyCta => 'Subscribe — \$29.99/yr';

  @override
  String get subscribeCloudSyncPlusMonthlyCta => 'Subscribe — \$4.99/mo';

  @override
  String get subscribeCloudSyncPlusYearlyCta => 'Subscribe — \$49.99/yr';

  @override
  String get signInRequiredBeforePurchase => 'Sign-in required before purchase';

  @override
  String get terms => 'Terms';

  @override
  String get privacy => 'Privacy';

  @override
  String get comparePlans => 'Compare Plans';

  @override
  String get featureCloudSyncPersonal => 'Cloud sync (personal)';

  @override
  String get featurePhotosOnSteps => 'Photos on steps';

  @override
  String get featurePhotoStorage250 => '250 MB photo storage (~500 photos)';

  @override
  String get featureRpgCosmeticsStarter => 'RPG cosmetics starter pack';

  @override
  String get featureSupporterBadge => 'Premium supporter badge';

  @override
  String get featureExtraPolish => 'Extra UI polish & QoL features';

  @override
  String get featureFamilySharing5 => 'Family sharing (5 members)';

  @override
  String get featurePhotoStorage1gb => '1 GB photo storage (~2,000 photos)';

  @override
  String get featureSharedLists => 'Shared shopping lists';

  @override
  String get featureSharedCookbooks => 'Shared cookbooks';

  @override
  String get featureSharedMealPlan => 'Shared meal planning';

  @override
  String get featureEncryptedBackups => 'Encrypted backups + version history';

  @override
  String get featureFamilySharing10 => 'Family sharing (10 members)';

  @override
  String get featurePhotoStorage5gb => '5 GB photo storage (~10,000 photos)';

  @override
  String get featureExtendedVersionHistory => 'Extended version history';

  @override
  String get featurePrioritySync => 'Priority sync performance';

  @override
  String get featureFutureAdvanced => 'Future advanced features included';

  @override
  String get tierCloudSync => 'Cloud\nSync';

  @override
  String get tierCloudSyncPlus => 'Cloud\nSync+';

  @override
  String get comparePrice => 'Price';

  @override
  String get priceFree => '\$0';

  @override
  String get pricePremium => '\$6.99\nonce';

  @override
  String get priceCloudSync => '\$2.99\n/mo';

  @override
  String get priceCloudSyncPlus => '\$4.99\n/mo';

  @override
  String get compareDeviceTransfer => 'Device transfer';

  @override
  String get qrCode => 'QR code';

  @override
  String get cloud => 'Cloud';

  @override
  String get comparePhotoStorage => 'Photo storage';

  @override
  String get compareStepPhotos => 'Step photos';

  @override
  String get compareFamilySharing => 'Family sharing';

  @override
  String get compareSharedLists => 'Shared lists';

  @override
  String get compareSharedCookbooks => 'Shared cookbooks';

  @override
  String get compareSharedMealPlan => 'Shared meal plan';

  @override
  String get compareBackups => 'Backups';

  @override
  String get compareVersionHistory => 'Version history';

  @override
  String get light => 'Light';

  @override
  String get extended => 'Extended';

  @override
  String get compareRpgCosmetics => 'RPG cosmetics';

  @override
  String get basic => 'Basic';

  @override
  String get starterPack => 'Starter\npack';

  @override
  String get compareSupporterBadge => 'Supporter badge';

  @override
  String get printOf => 'of';

  @override
  String get printRecipe => 'Print';

  @override
  String get stackedLayout => 'Stacked Layout';

  @override
  String get tabbedLayout => 'Tabbed Layout';

  @override
  String get printLabelIngredients => 'Ingredients';

  @override
  String get printLabelInstructions => 'Instructions';

  @override
  String get printLabelNotes => 'Notes';

  @override
  String get printLabelPrep => 'Prep';

  @override
  String get printLabelCook => 'Cook';

  @override
  String get printLabelFooter => 'Printed from Recipe Spellbook';

  @override
  String get printLabelPage => 'Page';

  @override
  String get printLabelOf => 'of';

  @override
  String get smallerText => 'Smaller text';

  @override
  String get largerText => 'Larger text';

  @override
  String get textSize => 'Text Size';

  @override
  String get ingredientPreview => 'Ingredient Preview';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get smartImportSuccess => 'Recipe re-parsed by AI';

  @override
  String smartImportSuccessWithRemaining(int remaining) {
    return 'Recipe re-parsed by AI • $remaining imports left this month';
  }

  @override
  String get smartImportLimitTitle => 'Smart Import Limit Reached';

  @override
  String smartImportLimitMessage(int limit) {
    return 'You\'\'ve used all $limit smart imports this month.';
  }

  @override
  String get smartImportUpgradeHint => 'Upgrade to Premium for 200 imports/month.';

  @override
  String get smartImportParsing => 'AI is parsing...';

  @override
  String get smartImportFix => 'Fix with Smart Import ✨';

  @override
  String smartImportRemaining(int remaining, int limit) {
    return '$remaining of $limit smart imports remaining this month';
  }

  @override
  String get smartImportHintTitle => 'Import not looking right?';

  @override
  String get smartImportHintSubtitle => 'Subscribe for Smart Import — AI-powered recipe parsing';

  @override
  String get learnMore => 'Learn more';

  @override
  String get retry => 'Retry';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get cookingMode => 'Cooking Mode';

  @override
  String get mealTypeDessert => 'Dessert';
}
