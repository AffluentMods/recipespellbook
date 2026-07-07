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
  String get settingsKitchenBuddy => 'Kitchen Buddy';

  @override
  String get settingsKitchenBuddySubtitle => 'A cute chef companion you dress up with coins';

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
  String get importFromFile => 'Import from file';

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
  String get shareFromApp => 'Shared from Recipe Spellbook';

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
  String get defaultImagesDescription => 'Default app artwork for recipes and cookbooks';

  @override
  String get themeBased => 'Theme-based';

  @override
  String get themeBasedDescription => 'Gradient with logo based on your color theme';

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
  String get resetScopeLocal => 'local data';

  @override
  String get resetScopeCloud => 'cloud data';

  @override
  String get resetScopeAll => 'all data, cloud sync, and your account';

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
  String get settingsKitchenBuddyActive => 'Your Kitchen Buddy is ready to cook!';

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
  String get unsavedChangesTitle => 'Discard changes?';

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
  String get settingsKitchenBuddyEnabled => 'Earn coins and dress up your buddy!';

  @override
  String get settingsRecipeLayoutSubtitle => 'Customize how recipes are displayed';

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
  String get recipeDeleted => 'Recipe deleted';

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
  String get localDataDesc => 'Deletes recipes, cookbooks, meal plans, and shopping lists on this device only. Cloud data stays intact and will sync back.';

  @override
  String get allData => 'All Data';

  @override
  String get allDataDesc => 'Permanently deletes EVERYTHING — local data, cloud data, and your account. Complete fresh start.';

  @override
  String get allDataWarningTitle => 'This will delete everything';

  @override
  String get allDataWarningCloudData => 'All recipes, cookbooks, and meal plans synced to the cloud';

  @override
  String get allDataWarningLocalData => 'All local data on this device';

  @override
  String get allDataWarningAccount => 'Your account (subscription restores automatically on sign-in)';

  @override
  String get allDataWarningSettings => 'All app settings and preferences';

  @override
  String get allDataIUnderstand => 'I understand this will permanently delete all my data';

  @override
  String get allDataNoUndo => 'I understand this action cannot be undone';

  @override
  String get localNoCloudWarning => 'You don\'t have Cloud Sync — there is no backup to recover from';

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
  String get menuShareMessage => 'Check out Recipe Spellbook - the best recipe app! https://recipespellbook.app/get';

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
  String get accountSubscription => 'Subscription';

  @override
  String get accountManageSubscription => 'Manage Subscription';

  @override
  String get accountCloudSync => 'Cloud Sync';

  @override
  String get accountSyncNow => 'Sync Now';

  @override
  String get accountIntegrations => 'Integrations';

  @override
  String get accountDangerZone => 'Danger Zone';

  @override
  String get purchasesRestored => 'Purchases restored successfully!';

  @override
  String get noPurchasesFound => 'No previous purchases found.';

  @override
  String get restoreFailed => 'Restore failed. Please try again.';

  @override
  String get restorePurchasesLong => 'Restore Purchases';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get accessUntil => 'access until';

  @override
  String get renews => 'Renews';

  @override
  String get plan => 'Plan';

  @override
  String get upgradeDescription => 'Unlock cloud sync, smart import, and more.';

  @override
  String get syncDescription => 'Keep your recipes synced across devices.';

  @override
  String get sync => 'Sync';

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
  String get tierPremium => 'PREMIUM';

  @override
  String get tierStandard => 'Standard';

  @override
  String get tierBasic => 'Basic';

  @override
  String get tierFree => 'FREE';

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
  String get cloudSyncFreeTrial => 'Try free for 1 week';

  @override
  String get subscribeCloudSyncMonthlyTrialCta => 'Start free trial — then \$2.99/mo';

  @override
  String get subscribeCloudSyncYearlyTrialCta => 'Start free trial — then \$29.99/yr';

  @override
  String get cloudSyncFeature => 'Cloud Sync';

  @override
  String get cloudSyncFamilyFeature => 'Cloud Sync Family';

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
  String get menuKitchenBuddyMode => 'KITCHEN BUDDY';

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
  String get featureCloudStorageLimited => 'Cloud storage — Limited';

  @override
  String get featureFamilySharing5 => 'Family sharing (5 members)';

  @override
  String get featureCloudStorage => 'Cloud storage';

  @override
  String get featureSharedLists => 'Shared shopping lists';

  @override
  String get featureSharedCookbooks => 'Shared cookbooks';

  @override
  String get featureSharedMealPlan => 'Shared meal planning';

  @override
  String get featureAutoBackups => 'Automatic backups';

  @override
  String get featureFamilySharing10 => 'Family sharing (10 members)';

  @override
  String get featurePrioritySync => 'Priority sync performance';

  @override
  String get featureFutureAdvanced => 'Future advanced features included';

  @override
  String get tierCloudSync => 'CLOUD SYNC';

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
  String get compareCloudStorage => 'Cloud Storage';

  @override
  String get compareCloudStorageBasic => 'Basic';

  @override
  String get compareCloudStorageStandard => 'Standard';

  @override
  String get compareCloudStorageExtended => 'Extended';

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
  String get learnMore => 'Learn more';

  @override
  String get retry => 'Retry';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get cookingMode => 'Cooking Mode';

  @override
  String get mealTypeDessert => 'Dessert';

  @override
  String get noContentToSave => 'No content to save';

  @override
  String get recipeSaved => 'Recipe saved!';

  @override
  String get qrScanningMobileOnly => 'QR scanning is only available on mobile devices.';

  @override
  String get communityComingSoon => 'Community features coming in a future update!';

  @override
  String somethingWentWrong(String error) {
    return 'Something went wrong: $error';
  }

  @override
  String starterRecipesAdded(int count) {
    return 'Added $count starter recipes! 🎉';
  }

  @override
  String get enterAtLeastOneNutrient => 'Enter at least calories or one macro nutrient';

  @override
  String addedToMealPlan(String mealType, String date) {
    return 'Added to $mealType on $date';
  }

  @override
  String get noItemsFoundInText => 'No items found in text';

  @override
  String get noTextFoundInImage => 'No text found in image';

  @override
  String get addDayToShoppingList => 'Add day to shopping list';

  @override
  String get sendDayToShoppingList => 'Send day to shopping list';

  @override
  String get removeMeal => 'Remove Meal';

  @override
  String removeMealConfirm(String recipeName) {
    return 'Remove $recipeName from this day?';
  }

  @override
  String get actionRemove => 'Remove';

  @override
  String get plannerMealRemoved => 'Meal removed';

  @override
  String plannerMealsRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals removed',
      one: '1 meal removed',
    );
    return '$_temp0';
  }

  @override
  String plannerMealsMoved(String date) {
    return 'Moved to $date';
  }

  @override
  String get plannerChangeMealType => 'Change meal type';

  @override
  String get plannerMoveToDate => 'Move to date';

  @override
  String get weekStartsOn => 'Week starts on';

  @override
  String get monday => 'Monday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get ingredientHeader => 'Header';

  @override
  String get ingredientHeaderHint => 'e.g., For the sauce';

  @override
  String get settingsWeekStartDay => 'Week starts on';

  @override
  String get settingsSurpriseMe => 'Show \'Surprise Me\' card';

  @override
  String get settingsSurpriseMeSubtitle => 'Show recipe suggestion card on home screen';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotifCooking => 'Cooking Reminders';

  @override
  String get settingsNotifCookingSubtitle => 'Meal plan alerts and cooking reminders';

  @override
  String get settingsNotifCommunity => 'Community Updates';

  @override
  String get settingsNotifCommunitySubtitle => 'Downloads, ratings, and comments on your recipes';

  @override
  String get settingsNotifAchievements => 'Achievements';

  @override
  String get settingsNotifAchievementsSubtitle => 'Achievement unlocks and milestone alerts';

  @override
  String get settingsNotifBuddy => 'Buddy Reminders';

  @override
  String get settingsNotifBuddySubtitle => 'Kitchen Buddy login streaks and coin bonuses';

  @override
  String get settingsNotifManagePreferences => 'Manage notification preferences';

  @override
  String get settingsNotifNewDownloads => 'New downloads';

  @override
  String get settingsNotifNewDownloadsSubtitle => 'When someone downloads your published recipe';

  @override
  String get settingsNotifRatingUpdates => 'Rating updates';

  @override
  String get settingsNotifRatingUpdatesSubtitle => 'When your published recipe gets a new rating';

  @override
  String get settingsNotifComments => 'Comments';

  @override
  String get settingsNotifCommentsSubtitle => 'When someone comments on your recipe';

  @override
  String get settingsNotifSyncNote => 'Notification preferences are synced with your account.';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String shoppingAddedToList(int count, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'items',
      one: 'item',
    );
    return 'Added $count $_temp0 to \"$listName\"';
  }

  @override
  String shoppingAddedAndCombined(int added, int combined, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: 'items',
      one: 'item',
    );
    return 'Added $added $_temp0 to \"$listName\", $combined combined';
  }

  @override
  String shoppingItemsUpdated(int count, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'items',
      one: 'item',
    );
    return '$count $_temp0 updated on \"$listName\"';
  }

  @override
  String shoppingAddError(String message) {
    return 'Error: $message';
  }

  @override
  String get editCookbook => 'Edit Cookbook';

  @override
  String get newCookbook => 'New Cookbook';

  @override
  String get tapToAddCoverImage => 'Tap to add cover image';

  @override
  String get cookbookDescriptionLabel => 'Description';

  @override
  String get cookbookDescriptionHint => 'A collection of recipes...';

  @override
  String get cookbookNameRequired => 'Please enter a name';

  @override
  String get addCover => 'Add Cover';

  @override
  String recipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recipes',
      one: 'recipe',
    );
    return '$count $_temp0';
  }

  @override
  String cookbookDeleteWithRecipes(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recipes',
      one: 'recipe',
    );
    return 'This cookbook contains $count $_temp0. They will be moved to trash.\n\nAre you sure you want to delete \"$name\"?';
  }

  @override
  String cookbookDeleteConfirmNamed(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get shareCookbook => 'Share Cookbook';

  @override
  String get cookbookEmpty => 'This cookbook has no recipes to share';

  @override
  String get recipes => 'recipes';

  @override
  String get sendSuggestion => 'Send a Suggestion';

  @override
  String get sendSuggestionSubtitle => 'Help us improve Recipe Spellbook';

  @override
  String get reportBug => 'Report a Bug';

  @override
  String get reportBugSubtitle => 'Something not working right?';

  @override
  String get joinDiscord => 'Join our Discord';

  @override
  String get joinDiscordSubtitle => 'Get help, chat, and share recipes';

  @override
  String get actionSend => 'Send';

  @override
  String get suggestionDescription => 'We\'d love to hear your ideas! Your suggestion will be sent directly to our team.';

  @override
  String get suggestionTitleLabel => 'Suggestion Title';

  @override
  String get suggestionTitleHint => 'e.g., Add dark mode for cooking screen';

  @override
  String get suggestionDetailsLabel => 'Details';

  @override
  String get suggestionDetailsHint => 'Describe your idea in detail...';

  @override
  String get contactOptionalLabel => 'Contact (optional)';

  @override
  String get contactOptionalHint => 'Email or Discord username';

  @override
  String get suggestionSent => 'Thanks! Your suggestion has been sent 💡';

  @override
  String get bugDescription => 'Found a bug? Let us know and we\'ll squash it. Device info is included automatically.';

  @override
  String get bugTitleLabel => 'Bug Title';

  @override
  String get bugTitleHint => 'e.g., App crashes when importing PDF';

  @override
  String get bugDetailsLabel => 'What happened?';

  @override
  String get bugDetailsHint => 'Describe what went wrong...';

  @override
  String get bugStepsLabel => 'Steps to Reproduce (optional)';

  @override
  String get bugStepsHint => '1. Open recipe\n2. Tap share\n3. App crashes';

  @override
  String get bugReportSent => 'Thanks! Your bug report has been sent 🐛';

  @override
  String get feedbackFieldsRequired => 'Please fill in the title and details';

  @override
  String get feedbackSendError => 'Couldn\'t send feedback. Check your internet connection.';

  @override
  String get mealTypeAppetizer => 'Appetizer';

  @override
  String get allergenContains => 'Contains';

  @override
  String get settingsIngredientLayout => 'Ingredient Layout';

  @override
  String get ingredientLayoutInline => 'Inline — 1 tsp butter';

  @override
  String get ingredientLayoutColumnar => 'Columnar — amounts aligned';

  @override
  String get settingsIngredientLayoutDescription => 'Choose how ingredient amounts and names are displayed in recipes, shopping lists, and print.';

  @override
  String get ingredientLayoutInlineDescription => 'Amount, unit, and name flow together naturally';

  @override
  String get ingredientLayoutColumnarDescription => 'Amounts aligned in a fixed column for easy scanning';

  @override
  String get ingredientLayoutInfoText => 'This setting applies to recipe view, shopping list generator, and printed recipes.';

  @override
  String get searchCookbooks => 'Search cookbooks...';

  @override
  String get aboutWebsite => 'Website';

  @override
  String get aboutPrivacyPolicy => 'Privacy Policy';

  @override
  String get aboutPrivacyPolicySub => 'How we handle your data';

  @override
  String get aboutTermsOfService => 'Terms of Service';

  @override
  String get aboutTermsOfServiceSub => 'Usage terms and conditions';

  @override
  String get aboutCommunity => 'Community';

  @override
  String get aboutCommunitySub => 'Join our Discord server';

  @override
  String get aboutReportBug => 'Report a Bug';

  @override
  String get aboutReportBugSub => 'Help us improve the app';

  @override
  String get aboutRateApp => 'Rate the App';

  @override
  String get aboutRateAppSub => 'Leave a review on the store';

  @override
  String get aboutLicenses => 'Open Source Licenses';

  @override
  String get aboutLicensesSub => 'Third-party software used';

  @override
  String get sortOrder => 'Sort Order';

  @override
  String get ingredientAddHeader => 'Add Header';

  @override
  String get saveAsRecipe => 'Save as Recipe';

  @override
  String get exportFullBackup => 'Full Backup';

  @override
  String get exportCookbooksRecipes => 'Cookbooks & Recipes';

  @override
  String get exportShoppingLists => 'Shopping Lists';

  @override
  String get exportMealPlans => 'Meal Plans';

  @override
  String get exportTags => 'Tags';

  @override
  String get exportCategories => 'Custom Categories';

  @override
  String get exportCourses => 'Custom Courses';

  @override
  String get createRecipeManually => 'Or create a recipe manually';

  @override
  String get transferYourRecipes => 'Transfer your recipes';

  @override
  String get transferUpgradeBanner => 'Want automatic sync? Upgrade to Premium for cloud sync across all your devices.';

  @override
  String get transferCodeLength => 'Code must be 6 characters';

  @override
  String get transferItemRecipes => 'All recipes';

  @override
  String get transferItemCookbooks => 'Cookbooks & categories';

  @override
  String get transferItemMealPlans => 'Meal plans';

  @override
  String get transferItemShoppingLists => 'Shopping lists';

  @override
  String get transferItemSettings => 'App settings';

  @override
  String get transferItemAccount => 'Account sign-in (if sender is logged in)';

  @override
  String get codeCopied => 'Code copied!';

  @override
  String get transferTitle => 'Transfer Data';

  @override
  String get transferReceiveSubtitle => 'Enter a code or scan QR from the sending device';

  @override
  String get transferPreparing => 'Preparing your data...';

  @override
  String get transferFailed => 'Transfer failed';

  @override
  String get transferScanDesc => 'Scan this QR on your other device, or enter the code below.';

  @override
  String get transferReady => 'Ready to transfer';

  @override
  String get transferCodeExpires => 'This code expires in 1 hour';

  @override
  String get transferComplete => 'Transfer complete!';

  @override
  String get transferAccountSynced => 'Account signed in from sender';

  @override
  String get transferScanQr => 'Scan QR Code';

  @override
  String get transferScanQrDesc => 'Point your camera at the QR on the other device';

  @override
  String get transferEnterCode => 'Enter transfer code';

  @override
  String get transferWhatMoves => 'What gets transferred:';

  @override
  String get transferMergeNote => 'Existing data on this device will be merged. Duplicates are skipped.';

  @override
  String get transferPointCamera => 'Point at the QR code on the sending device';

  @override
  String get labelPrepMin => 'Prep (min)';

  @override
  String get labelCookMin => 'Cook (min)';

  @override
  String get labelTotalCal => 'Total cal';

  @override
  String get labelCalPerServing => 'Cal/serving';

  @override
  String get tooltipViewSize => 'View size';

  @override
  String get pantryClearTitle => 'Clear pantry?';

  @override
  String get pantryAddHint => 'Add item to pantry...';

  @override
  String get pantryAddStaples => 'Add all staples';

  @override
  String get pantrySearchHint => 'Search pantry...';

  @override
  String get settingsRecipesShopping => 'Recipes & Shopping';

  @override
  String get settingsAdvanced => 'Advanced Settings';

  @override
  String get settingsAdvancedSubtitle => 'Tags, courses, categories & more';

  @override
  String get settingsRestoreDefaults => 'Restore Default Recipes';

  @override
  String get settingsRestoreDefaultsSubtitle => 'Re-add the 10 starter recipes';

  @override
  String get settingsRestoreDefaultsConfirm => 'Add 10 starter recipes to your cookbook? Existing recipes won\'t be affected.';

  @override
  String get settingsDeleteData => 'Delete Data';

  @override
  String get settingsDeleteDataSubtitle => 'Erase app or cloud data';

  @override
  String get settingsUpgradeSubtitle => 'Cloud sync, photos & more';

  @override
  String get settingsTextSizeSubtitle => 'Adjust text size across the entire app';

  @override
  String get settingsGoogleOrApple => 'Google or Apple';

  @override
  String get alwaysVisible => 'Always visible';

  @override
  String get chartNumbers => 'Numbers';

  @override
  String get chartDonut => 'Donut';

  @override
  String get chartBars => 'Bars';

  @override
  String get unitKcal => 'kcal';

  @override
  String get nutritionCustomScale => 'Custom Scale';

  @override
  String get nutritionScaleLabel => 'Scale multiplier';

  @override
  String get nutritionScaleHint => 'e.g. 0.5, 1.5, 3.0';

  @override
  String get nutritionSet => 'Set';

  @override
  String get nutritionApplyRecalculate => 'Apply & Recalculate';

  @override
  String get calAbbrev => 'Cal';

  @override
  String get nutritionServingSizeHint => 'e.g., 1 cup, 100g';

  @override
  String get shoppingExportList => 'Export list';

  @override
  String get shoppingExportListSubtitle => 'Share as a text file or backup';

  @override
  String get shoppingImportList => 'Import list';

  @override
  String get shoppingImportListSubtitle => 'Add items from a file, photo, or text';

  @override
  String get shoppingScanBarcodeSubtitle => 'Look up a product to add';

  @override
  String get exportBackupFile => 'Backup file';

  @override
  String get exportBackupFileSubtitle => 'For transferring to another device or app';

  @override
  String get exportFormattedList => 'Formatted list';

  @override
  String get exportFormattedListSubtitle => 'With checkboxes — great for notes apps';

  @override
  String get exportPlainText => 'Plain text';

  @override
  String get exportPlainTextSubtitle => 'Simple list — paste anywhere';

  @override
  String get importFromBackupFile => 'From backup file';

  @override
  String get importFromBackupSubtitle => 'Import a Recipe Spellbook backup';

  @override
  String get importFromTextShoppingSubtitle => 'Paste or type a list of items';

  @override
  String get importFromPhotoOcrSubtitle => 'OCR scan a handwritten or printed list';

  @override
  String get importFromPhotoGallerySubtitle => 'Take a photo or pick from gallery';

  @override
  String get shoppingSendToStore => 'Send to store';

  @override
  String get shoppingSendToCart => 'Send to cart';

  @override
  String get shoppingCopyToClipboard => 'Copy list to clipboard';

  @override
  String get shoppingGoToCart => 'Go to cart';

  @override
  String get shoppingAddItems => 'Add items';

  @override
  String get shoppingAddItemHintLong => 'e.g. 2 cups flour, chicken breast...';

  @override
  String get importReviewItems => 'Review items';

  @override
  String get importNoItemsDetected => 'No items detected';

  @override
  String get mealPlanDate => 'Date';

  @override
  String get mealPlanThisWeekend => 'This Weekend';

  @override
  String get menuKitchenBuddy => 'Kitchen Buddy';

  @override
  String get menuTools => 'Tools';

  @override
  String get menuSupport => 'Support';

  @override
  String get menuHowCanWeHelp => 'How can we help?';

  @override
  String get menuGetInTouch => 'Get in touch or browse our guides.';

  @override
  String get menuVisitWebsite => 'Visit our Website';

  @override
  String get feedbackTitleLabel => 'Title';

  @override
  String get feedbackDetailsLabel => 'Details';

  @override
  String get feedbackDescriptionLabel => 'Description';

  @override
  String get menuSigningIn => 'Signing in…';

  @override
  String get menuSignInSync => 'Sign in to sync & back up';

  @override
  String get tagsSave => 'Save Tags';

  @override
  String get recipeFieldCategories => 'Categories';

  @override
  String get selectCategories => 'Select categories';

  @override
  String get searchOrCreateNew => 'Search or create new...';

  @override
  String get noMatchesFound => 'No matches found';

  @override
  String get taxonomyAddCategoryNew => 'Add as new category';

  @override
  String get ingredientSubstitutionsTitle => 'Ingredient Substitutions';

  @override
  String get ingredientSubstitutionsSearch => 'Search for an ingredient...';

  @override
  String get ingredientSubstitutionsSearchAll => 'Search all substitutions';

  @override
  String get ingredientName => 'Ingredient Name';

  @override
  String get ingredientNameHint => 'e.g. turmeric, tahini, miso';

  @override
  String get ingredientBulkHint => 'Enter one ingredient per line:\n\n2 cups flour\n1 tsp salt\n3 eggs';

  @override
  String get viewPlans => 'View Plans';

  @override
  String get renewsLabel => 'Renews';

  @override
  String get upgradeToProUnlock => 'Upgrade to Pro to unlock';

  @override
  String get kitchenBuddyTitle => 'Kitchen Buddy';

  @override
  String get kitchenBuddyCloset => 'Closet';

  @override
  String get kitchenBuddyShop => 'Shop';

  @override
  String get kitchenBuddyAchievements => 'Achievements';

  @override
  String kitchenBuddyStreakDays(int count) {
    return '$count day streak';
  }

  @override
  String get kitchenBuddyClosetEmpty => 'No items yet! Visit the Shop to get started.';

  @override
  String get kitchenBuddyShopOwnEverything => 'You own everything!';

  @override
  String get kitchenBuddyShopCheckBack => 'Check back when new items are added.';

  @override
  String kitchenBuddyConfirmPurchase(String itemName) {
    return 'Buy $itemName?';
  }

  @override
  String kitchenBuddyCostSummary(int price) {
    return 'This will cost 🪙 $price Spice Coins.';
  }

  @override
  String get kitchenBuddyBuy => 'Buy';

  @override
  String kitchenBuddyPurchaseSuccess(String itemName) {
    return 'Purchased $itemName!';
  }

  @override
  String get kitchenBuddyNotEnoughCoins => 'Not enough coins';

  @override
  String kitchenBuddyRequires(String achievementName) {
    return 'Requires: $achievementName';
  }

  @override
  String get kitchenBuddyNamingTitle => 'Name Your Buddy';

  @override
  String get kitchenBuddyIntroTitle => 'Meet your Kitchen Buddy!';

  @override
  String get kitchenBuddyIntroDescription => 'This little chef will be your kitchen companion.\nCook recipes and earn coins to dress them up!';

  @override
  String get kitchenBuddyNameLabel => 'Buddy Name';

  @override
  String get kitchenBuddyNameHint => 'Enter a name...';

  @override
  String get kitchenBuddyCreate => 'Create Buddy';

  @override
  String get settingsNoMatchingSettings => 'No matching settings';

  @override
  String get settingsSearchHint => 'Search settings...';

  @override
  String get textSizeSmall => 'Small';

  @override
  String get textSizeDefault => 'Default';

  @override
  String get textSizeMedium => 'Medium';

  @override
  String get textSizeLarge => 'Large';

  @override
  String get textSizeExtraLarge => 'Extra Large';

  @override
  String get resetDataClearedDesc => 'All data has been cleared successfully.\n\nWould you like to import the 10 default starter recipes?';

  @override
  String get yesImport => 'Yes, Import';

  @override
  String get importingDefaultRecipes => 'Importing default recipes...';

  @override
  String get checking => 'Checking...';

  @override
  String get connectedTapToManage => 'Connected • Tap to manage';

  @override
  String get notConnected => 'Not connected';

  @override
  String get tapToSignIn => 'Tap to sign in';

  @override
  String get noneSelected => 'None Selected';

  @override
  String get partialBackup => 'Partial Backup';

  @override
  String get settingsShopping => 'Shopping & Planning';

  @override
  String get settingsManage => 'Manage';

  @override
  String get manageTags => 'Manage Tags';

  @override
  String tagsApplied(int count) {
    return '$count tags applied';
  }

  @override
  String tagsEditTitle(String name) {
    return 'Edit \"$name\"';
  }

  @override
  String get tagsEditComingSoon => 'Tag editing coming soon!';

  @override
  String tagsRecipeCount(int count) {
    return '$count recipes';
  }

  @override
  String get communityMyPublications => 'My Publications';

  @override
  String get communitySearchCookbooks => 'Search cookbooks...';

  @override
  String get communitySortRecent => 'Recent';

  @override
  String get communitySortPopular => 'Popular';

  @override
  String get communitySortMostDownloaded => 'Most Downloaded';

  @override
  String communityNoResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get communityNoCookbooksYet => 'No cookbooks yet';

  @override
  String get communityClearSearch => 'Clear search';

  @override
  String get communityPublish => 'Publish';

  @override
  String communityByPublisher(String name) {
    return 'by $name';
  }

  @override
  String communityRecipeCount(int count) {
    return '$count recipes';
  }

  @override
  String get communityPublishCookbook => 'Publish Cookbook';

  @override
  String get communitySignInToPublish => 'Sign in to publish';

  @override
  String get communitySignInToPublishMessage => 'You need an account to share cookbooks with the community.';

  @override
  String get communityGoToSettings => 'Go to Settings';

  @override
  String get communityNoCookbooksToPublish => 'No cookbooks to publish';

  @override
  String get communityPublishInfo => 'Cookbooks need at least 5 recipes to publish. Your recipes will be shared as a snapshot — updates won\'t sync.';

  @override
  String get communitySelectCookbook => 'Select a cookbook to publish';

  @override
  String communityNeedMinRecipes(int count) {
    return 'Need at least 5 recipes to publish (has $count)';
  }

  @override
  String get communityPublishConfirmTitle => 'Publish to Community?';

  @override
  String communityPublishConfirmMessage(String name, int count) {
    return 'This will share \"$name\" ($count recipes) publicly. Anyone can browse and download it.\n\nYou can unpublish it anytime.';
  }

  @override
  String communityPublishSuccess(String name) {
    return '\"$name\" published to the community!';
  }

  @override
  String get communityPublishFailed => 'Publish failed';

  @override
  String communityRecipeCountNeedMore(int count) {
    return '$count recipes (need 5+)';
  }

  @override
  String get communityNoPublicationsYet => 'No publications yet';

  @override
  String get communityNoPublicationsMessage => 'Publish a cookbook to share it with the community.';

  @override
  String get communityUnpublish => 'Unpublish';

  @override
  String get communityUnpublishConfirmTitle => 'Unpublish?';

  @override
  String communityUnpublishConfirmMessage(String title) {
    return 'Remove \"$title\" from the community? People who already downloaded it will keep their copy.';
  }

  @override
  String communityUnpublishSuccess(String title) {
    return '\"$title\" unpublished';
  }

  @override
  String get communityUnpublishFailed => 'Failed to unpublish';

  @override
  String get communityRemovedByModeration => 'Removed by moderation';

  @override
  String communityPublicationStats(int recipeCount, int downloadCount, String timeAgo) {
    return '$recipeCount recipes · $downloadCount downloads · $timeAgo';
  }

  @override
  String get communityPublicationNotFound => 'Publication not found';

  @override
  String get communityReport => 'Report';

  @override
  String get communityReportTitle => 'Report this cookbook';

  @override
  String get communityReportSpam => 'Spam or low quality';

  @override
  String get communityReportInappropriate => 'Inappropriate content';

  @override
  String get communityReportStolen => 'Stolen / copied recipes';

  @override
  String get communityReportOther => 'Other';

  @override
  String get communityReportSuccess => 'Report submitted. Thank you!';

  @override
  String get communitySignInToReport => 'Sign in to report content';

  @override
  String get communityDownloadFailed => 'Download failed';

  @override
  String communityDownloadSuccess(String title, int count) {
    return 'Downloaded \"$title\" — $count recipes added!';
  }

  @override
  String communityDownloadFailedError(String error) {
    return 'Download failed: $error';
  }

  @override
  String communityDownloadCount(int count) {
    return '$count downloads';
  }

  @override
  String get communityDownloading => 'Downloading...';

  @override
  String get communityDownloadToMyCookbooks => 'Download to My Cookbooks';

  @override
  String communityPrepTime(int minutes) {
    return '${minutes}m prep';
  }

  @override
  String communityCookTime(int minutes) {
    return '${minutes}m cook';
  }

  @override
  String communityServingsCount(int count) {
    return '$count servings';
  }

  @override
  String communityIngredientCount(int count) {
    return '$count ingredients';
  }

  @override
  String get deleteRecipesTrashMessage => 'Recipes will be moved to trash. You can restore them later.';

  @override
  String get hintTitleExample => 'e.g., Grandma\'s Apple Pie';

  @override
  String get hintDescription => 'A brief description of the recipe';

  @override
  String get hintServingsExample => 'e.g., 4';

  @override
  String get prepMin => 'Prep (min)';

  @override
  String get cookMin => 'Cook (min)';

  @override
  String get hintNotes => 'Tips, variations, storage instructions...';

  @override
  String get pinchToZoomCropped => 'Pinch to zoom · Cropped area will be saved';

  @override
  String get pinchToZoomOrUseAsIs => 'Pinch to zoom and crop · Or use as-is';

  @override
  String get savingLabel => 'Saving...';

  @override
  String get emptyHeader => '(empty header)';

  @override
  String get emptyIngredient => '(empty ingredient)';

  @override
  String get recipeUpdated => 'Recipe updated!';

  @override
  String get nutritionLessInfo => 'Less info';

  @override
  String get nutritionMoreInfo => 'More info';

  @override
  String scaleOriginal(String servings) {
    return 'Original: $servings';
  }

  @override
  String get scaleAdjustQuantities => 'Adjust ingredient quantities';

  @override
  String get scaleOriginalLabel => '1x (Original)';

  @override
  String get stepWillBeRemoved => 'This step will be permanently removed.';

  @override
  String stepsWillBeRemoved(int count) {
    return 'These $count steps will be permanently removed.';
  }

  @override
  String stepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String get instructionsNoSteps => 'No instructions yet';

  @override
  String get instructionsAddStepsGuide => 'Add steps to guide through the recipe';

  @override
  String get pinchToZoomPreview => 'Pinch to zoom · This is how your photo will look';

  @override
  String ingredientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredients',
      one: '1 ingredient',
    );
    return '$_temp0';
  }

  @override
  String get ingredientPerLineHint => 'Enter one ingredient per line:\n\n2 cups flour\n1 tsp salt\n3 eggs';

  @override
  String get ingredientTip => 'Tip: Enter one ingredient per line. Press Enter after each ingredient.';

  @override
  String get cookbookEditSubtitle => 'Rename, cover photo';

  @override
  String get shareCookbookSubtitle => 'Link, family, or community';

  @override
  String shareNamedCookbook(String name) {
    return 'Share \"$name\"';
  }

  @override
  String shareNamedList(String name) {
    return 'Share \"$name\"';
  }

  @override
  String get shareAsTextDescription => 'Send list items as plain text';

  @override
  String get oneTimeLink => 'One-Time Link';

  @override
  String get oneTimeLinkDescription => 'Free • 24h expiry • Anyone can download';

  @override
  String get familyShare => 'Family Share';

  @override
  String get familyShareDescription => 'Real-time sync with family members';

  @override
  String get postToCommunity => 'Post to Community';

  @override
  String get postToCommunityDescription => 'Publish for anyone to discover & download';

  @override
  String get signInToShare => 'Sign in to create share links';

  @override
  String get generatingLink => 'Generating link...';

  @override
  String get failedToCreateLink => 'Failed to create link';

  @override
  String get linkCreated => 'Link Created!';

  @override
  String get expiresIn24Hours => 'Expires in 24 hours';

  @override
  String get linkCopied => 'Link copied!';

  @override
  String unlockFeature(String feature) {
    return 'Unlock $feature';
  }

  @override
  String get notNow => 'Not now';

  @override
  String get upgradeButton => 'Upgrade';

  @override
  String publishMinRecipes(int count) {
    return 'Need at least 10 recipes to publish (has $count)';
  }

  @override
  String get publishConfirmTitle => 'Post to Community?';

  @override
  String publishConfirmMessage(String name, int count) {
    return '\"$name\" ($count recipes) will be publicly visible. Anyone can browse and download it.\n\nYou can remove it anytime from Community → My Publications.';
  }

  @override
  String get publishButton => 'Publish';

  @override
  String get selectCourse => 'Select Course';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get taxonomyNone => 'None';

  @override
  String createTaxonomy(String name) {
    return 'Create \"$name\"';
  }

  @override
  String get addAsNewCourse => 'Add as new course';

  @override
  String get addAsNewCategory => 'Add as new category';

  @override
  String doneWithCount(int count) {
    return 'Done ($count)';
  }

  @override
  String get quickAccessEmptyAll => 'No quick access recipes yet';

  @override
  String get quickAccessEmptyMealPlan => 'No meals planned';

  @override
  String get quickAccessEmptyPinned => 'No pinned recipes';

  @override
  String get quickAccessEmptyRecent => 'No recent recipes';

  @override
  String get importingRecipe => 'Importing recipe…';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get minutesPrepSuffix => 'm prep';

  @override
  String get minutesCookSuffix => 'm cook';

  @override
  String get couldNotOpenBrowser => 'Could not open browser';

  @override
  String couldNotOpenUrl(String url) {
    return 'Could not open $url';
  }

  @override
  String get discord => 'Discord';

  @override
  String get discordLinkAccount => 'Link Discord Account';

  @override
  String get discordLinkSubtitle => 'Connect your Discord for community features';

  @override
  String get discordSignInFirst => 'Sign in first to link Discord';

  @override
  String get discordUnlink => 'Unlink Discord';

  @override
  String get discordUnlinkFailed => 'Failed to unlink Discord';

  @override
  String get discordUnlinkSubtitle => 'Remove your Discord connection';

  @override
  String get discordUnlinked => 'Discord unlinked';

  @override
  String get familyCodeCopied => 'Invite code copied!';

  @override
  String get familyCopyLink => 'Copy Link';

  @override
  String get familyCreate => 'Create Family';

  @override
  String get familyCreateFailed => 'Failed to create family';

  @override
  String get familyCreateTitle => 'Create Family';

  @override
  String get familyCreated => 'Family created!';

  @override
  String get familyDelete => 'Delete Family';

  @override
  String get familyDeleteConfirm => 'Are you sure you want to delete this family? All members will be removed.';

  @override
  String get familyDeleted => 'Family deleted';

  @override
  String get familyEnterInviteCode => 'Enter invite code';

  @override
  String get familyInvite => 'Invite Members';

  @override
  String get familyJoinAction => 'Join';

  @override
  String get familyJoinFailed => 'Failed to join family';

  @override
  String get familyJoinTitle => 'Join Family';

  @override
  String get familyJoinWithCode => 'Join with Code';

  @override
  String familyJoined(String familyName) {
    return 'Joined $familyName!';
  }

  @override
  String get familyLeave => 'Leave Family';

  @override
  String get familyLeaveAction => 'Leave';

  @override
  String get familyLeaveConfirm => 'Are you sure you want to leave this family?';

  @override
  String get familyLeft => 'Left family';

  @override
  String get familyLinkCopied => 'Invite link copied!';

  @override
  String get familyManage => 'Manage your family';

  @override
  String familyMemberRemoved(String displayName) {
    return '$displayName removed';
  }

  @override
  String get familyMembers => 'Members';

  @override
  String familyMembersCount(int current, int max) {
    return '$current of $max members';
  }

  @override
  String get familyNameHint => 'Family name';

  @override
  String get familyNewCodeGenerated => 'New invite code generated';

  @override
  String get familyOwner => 'OWNER';

  @override
  String get familyRegenerateCode => 'Regenerate Code';

  @override
  String get familyRemoveMember => 'Remove Member';

  @override
  String familyRemoveMemberConfirm(String displayName) {
    return 'Remove $displayName from the family?';
  }

  @override
  String get familyRename => 'Rename Family';

  @override
  String familyShareMessage(String inviteCode, String shareLink) {
    return 'Join my family on Recipe Spellbook! Code: $inviteCode or use this link: $shareLink';
  }

  @override
  String get familyShareSubject => 'Join my Recipe Spellbook family';

  @override
  String get familyShareUpgradeMessage => 'Upgrade to share cookbooks with family members in real-time.';

  @override
  String get familySharing => 'Family Sharing';

  @override
  String get familySharingDescription => 'Share cookbooks, shopping lists, and meal plans with your family.';

  @override
  String get familySharingSubtitle => 'Share cookbooks, lists & meal plans';

  @override
  String ingredientSubstitutesFor(String ingredientName) {
    return 'Substitutes for $ingredientName';
  }

  @override
  String get ingredientSubstitutionsNoResults => 'No substitutions found';

  @override
  String ingredientSubstitutionsNotFound(String ingredientName) {
    return 'No substitutions found for $ingredientName';
  }

  @override
  String get ingredientSubstitutionsTryDifferent => 'Try a different ingredient';

  @override
  String get integrationsChecking => 'Checking...';

  @override
  String get integrationsConnectedManage => 'Connected - Tap to manage';

  @override
  String get integrationsLinked => 'Linked';

  @override
  String get integrationsLinkedManage => 'Linked - Tap to manage';

  @override
  String get integrationsNotConnected => 'Not connected';

  @override
  String get integrationsTapToLink => 'Tap to link';

  @override
  String get integrationsTapToSignIn => 'Tap to sign in';

  @override
  String get nutritionCalculateFromEdit => 'Calculate from the edit screen';

  @override
  String get nutritionCaloriesAlwaysShow => 'Always show calories';

  @override
  String get nutritionChartStyle => 'Chart Style';

  @override
  String get nutritionResetDefaults => 'Reset to Defaults';

  @override
  String get nutritionSettingsLink => 'Nutrition settings';

  @override
  String get nutritionTapToCalculate => 'Tap to calculate nutrition';

  @override
  String get nutritionVisibleNutrients => 'Visible Nutrients';

  @override
  String pantryAddedStaples(int count) {
    return 'Added $count staples to pantry';
  }

  @override
  String get pantryClearAll => 'Clear All';

  @override
  String get pantryClearMessage => 'Remove all items from your pantry?';

  @override
  String get pantryCommonStaples => 'Common Staples';

  @override
  String get pantryEmpty => 'Your pantry is empty';

  @override
  String get pantryEmptySubtitle => 'Add items you always have on hand';

  @override
  String get pantryInfoMessage => 'Items in your pantry will be excluded from shopping lists when adding recipe ingredients.';

  @override
  String pantryItemCount(int count) {
    return '$count items';
  }

  @override
  String get mealPlanAddTitle => 'Add to Meal Plan';

  @override
  String get mealPlanMealLabel => 'Meal';

  @override
  String get mealPlanAdding => 'Adding...';

  @override
  String mealPlanDateFormat(String weekday, String month, int day) {
    return '$weekday, $month $day';
  }

  @override
  String get splashRecipe => 'Recipe';

  @override
  String get splashSpellbook => 'Spellbook';

  @override
  String get splashTagline => 'Your culinary adventure awaits';

  @override
  String get servingSizeHint => 'e.g., 1 cup, 100g';

  @override
  String get mainNutrients => 'Main Nutrients';

  @override
  String get additionalNutrients => 'Additional Nutrients';

  @override
  String get onboardingWelcomeTo => 'Welcome to';

  @override
  String get onboardingAppName => 'Recipe Spellbook!';

  @override
  String get onboardingDescription => '10 handpicked recipes from around the world to get you started.';

  @override
  String get onboardingDeleteLater => 'You can always delete them later.';

  @override
  String get onboardingAdding => 'Adding...';

  @override
  String get onboardingAddStarter => 'Add starter recipes';

  @override
  String get onboardingBlankCookbook => 'Start with a blank cookbook';

  @override
  String get onboardingBlankConfirmTitle => 'Start with nothing?';

  @override
  String get onboardingBlankConfirmBody => 'You can always add the starter recipes later from Settings.';

  @override
  String get onboardingBlankConfirmYes => 'Yes, start empty';

  @override
  String get onboardingSpellbookAwaits => 'Your Spellbook Awaits';

  @override
  String get onboardingYourSpellbookAwaits => 'Your spellbook awaits...';

  @override
  String get onboardingSummoning => 'Summoning...';

  @override
  String get onboardingBlankSpellbook => 'Start with a blank spellbook';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get settingsBrowseCommunity => 'Browse Community';

  @override
  String get settingsBrowseCommunitySubtitle => 'Discover public cookbooks';

  @override
  String get settingsCommunity => 'Community';

  @override
  String get settingsFamily => 'Family';

  @override
  String get settingsIntegrations => 'Integrations';

  @override
  String get settingsMyPublications => 'My Publications';

  @override
  String get settingsMyPublicationsSubtitle => 'Manage your published cookbooks';

  @override
  String get settingsShoppingPlanning => 'Shopping & Planning';

  @override
  String shoppingAddCountItems(int count) {
    return 'Add $count items';
  }

  @override
  String get shoppingAddIngredient => 'Add Ingredient';

  @override
  String shoppingAddedItemName(String name) {
    return 'Added \"$name\"';
  }

  @override
  String shoppingAddedNotFound(int added, int failed) {
    return '$added added, $failed not found';
  }

  @override
  String shoppingAddingTo(String provider) {
    return 'Adding to $provider…';
  }

  @override
  String get shoppingCamera => 'camera';

  @override
  String shoppingCheckedItemsCount(int count) {
    return 'Checked items ($count)';
  }

  @override
  String shoppingCouldNotAccessSource(String source) {
    return 'Could not access $source';
  }

  @override
  String shoppingCountAdded(int count) {
    return '$count added';
  }

  @override
  String shoppingCreatingListOn(String provider) {
    return 'Creating list on $provider…';
  }

  @override
  String shoppingCurrentOfTotal(int current, int total) {
    return '$current of $total items';
  }

  @override
  String shoppingDeleteListConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String shoppingErrorReadingImage(String error) {
    return 'Error reading image: $error';
  }

  @override
  String shoppingExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String shoppingExportTitle(String name) {
    return 'Export \"$name\"';
  }

  @override
  String get shoppingFamilyShare => 'Family Share';

  @override
  String get shoppingFamilyShareSubtitle => 'Share list with family or one-time link';

  @override
  String get shoppingFromPhoto => 'From photo';

  @override
  String get shoppingFromText => 'From text';

  @override
  String get shoppingGallery => 'gallery';

  @override
  String get shoppingImportItems => 'Import items';

  @override
  String get shoppingImportShoppingList => 'Import shopping list';

  @override
  String get shoppingImportTextHint => '2 cups flour\nchicken breast\n1 lb ground beef\nmilk\n...';

  @override
  String get shoppingImportedList => 'Imported List';

  @override
  String get shoppingIngredientHint => 'e.g., chicken breast, olive oil';

  @override
  String get shoppingIngredientName => 'Ingredient Name';

  @override
  String shoppingIngredientsAvailable(int count) {
    return '$count ingredients available';
  }

  @override
  String shoppingItemsAddedCount(int count) {
    return '$count items added';
  }

  @override
  String get shoppingItemsAddedSuccess => 'Items added!';

  @override
  String shoppingItemsCopiedToClipboard(int count) {
    return '$count items copied to clipboard';
  }

  @override
  String shoppingItemsInCart(int count, String provider) {
    return '$count items in your $provider cart';
  }

  @override
  String shoppingItemsOnInstacartList(int count) {
    return '$count items on your Instacart list';
  }

  @override
  String get shoppingJustAdded => 'Just added';

  @override
  String shoppingListCopiedOpening(String name) {
    return 'List copied! Opening $name...';
  }

  @override
  String get shoppingListReady => 'Shopping list ready!';

  @override
  String shoppingNotFoundItems(String items) {
    return 'Not found: $items';
  }

  @override
  String get shoppingOneItemPerLine => 'One item per line';

  @override
  String get shoppingPartiallyAdded => 'Partially added';

  @override
  String get shoppingProviderConnected => 'Connected';

  @override
  String get shoppingRemoveFromList => 'Remove from list';

  @override
  String get shoppingStartTyping => 'Start typing to see suggestions';

  @override
  String get shoppingTapToAddToCart => 'Tap to add items directly to your cart';

  @override
  String get shoppingTapToCreateShoppableList => 'Tap to create a shoppable list';

  @override
  String get swipeToSwitch => 'Swipe to switch sections';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String syncSuccess(int pushed, int pulled) {
    return 'Synced: $pushed pushed, $pulled pulled';
  }

  @override
  String get textSizePreview => 'Preview';

  @override
  String get transferDeviceDesktop => 'desktop';

  @override
  String get transferDeviceMobileApp => 'mobile app';

  @override
  String get transferDeviceThisDevice => 'this device';

  @override
  String transferExplanation(String currentDevice, String targetDevice) {
    return 'Move all your recipes, cookbooks, and meal plans from $currentDevice to your $targetDevice. This is a one-time copy, not a sync.';
  }

  @override
  String transferImportedSuccess(int count) {
    return '$count items imported successfully.';
  }

  @override
  String get transferOr => 'OR';

  @override
  String transferReceiveOn(String device) {
    return 'Receive on $device';
  }

  @override
  String transferSendFrom(String device) {
    return 'Send from $device';
  }

  @override
  String transferSendSubtitle(String device) {
    return 'Generate a code for your $device to receive';
  }

  @override
  String get importGuidesTitle => 'Import Guides';

  @override
  String get importGuidesOpenInBrowser => 'Open guides in browser';

  @override
  String get importGuideHeroTitle => 'Bring your recipes from anywhere';

  @override
  String get importGuideHeroSubtitle => 'Tap any guide below for step-by-step instructions with screenshots.';

  @override
  String get importGuideQuickTipLabel => 'Quick tip';

  @override
  String get importGuideQuickTipText => 'The fastest way? Copy any recipe link and share it to Recipe Spellbook — works from almost any app.';

  @override
  String get importGuideWebButton => 'Web';

  @override
  String get importGuideFollowInBrowser => 'Follow along in browser';

  @override
  String get importGuideTagPopular => 'Popular';

  @override
  String get importGuideTagEasiest => 'Easiest';

  @override
  String get importGuideDifficultyEasy => 'Easy';

  @override
  String get importGuideDifficultyMedium => 'Medium';

  @override
  String get importGuideTime15Sec => '15 sec';

  @override
  String get importGuideTime30Sec => '30 sec';

  @override
  String get importGuideTime1Min => '1 min';

  @override
  String get importGuideTime2To5Min => '2–5 min';

  @override
  String importGuideStepsCount(int count) {
    return '$count steps';
  }

  @override
  String get importGuideCategorySocial => 'Social Media';

  @override
  String get importGuideCategoryWebsites => 'Websites';

  @override
  String get importGuideCategoryPhotos => 'Photos & Files';

  @override
  String get importGuideCategoryOtherApps => 'Other Recipe Apps';

  @override
  String get importGuideCategoryAi => 'AI Import';

  @override
  String get importGuideTagNew => 'New';

  @override
  String get importGuideScreenshotNeeded => 'Screenshot needed';

  @override
  String get importGuideGifNeeded => 'GIF needed';

  @override
  String get importGuideVideoNeeded => 'Video needed';

  @override
  String get importGuideInstagramTitle => 'Instagram';

  @override
  String get importGuideInstagramSubtitle => 'Import from Reels, posts, and stories';

  @override
  String get importGuideInstagramStep1Title => 'Find a recipe post or Reel';

  @override
  String get importGuideInstagramStep1Desc => 'Open Instagram and find a recipe you want to save. This works with feed posts, Reels, and carousels.';

  @override
  String get importGuideInstagramStep2Title => 'Tap the share button';

  @override
  String get importGuideInstagramStep2Desc => 'Tap the paper plane icon (share) below the post.';

  @override
  String get importGuideInstagramStep3Title => 'Share to Recipe Spellbook';

  @override
  String get importGuideInstagramStep3Desc => 'Scroll the app row and tap Recipe Spellbook. If you don\'t see it, tap \"More\" and find it in the list.';

  @override
  String get importGuideInstagramStep3Tip => 'On Android, you can also copy the link and paste it in the app.';

  @override
  String get importGuideInstagramStep4Title => 'Find Recipe Spellbook';

  @override
  String get importGuideInstagramStep4Desc => 'Tap More to see all your apps, then find and tap Recipe Spellbook.';

  @override
  String get importGuideInstagramStep5Title => 'Preview & import';

  @override
  String get importGuideInstagramStep5Desc => 'Review the recipe details and tap Import to save it to your cookbook.';

  @override
  String get importGuideTiktokTitle => 'TikTok';

  @override
  String get importGuideTiktokSubtitle => 'Save recipes from cooking videos';

  @override
  String get importGuideTiktokStep1Title => 'Find a recipe TikTok';

  @override
  String get importGuideTiktokStep1Desc => 'Open TikTok and find a cooking video you want to save.';

  @override
  String get importGuideTiktokStep2Title => 'Tap the share arrow';

  @override
  String get importGuideTiktokStep2Desc => 'Tap the arrow icon on the right side of the video.';

  @override
  String get importGuideTiktokStep3Title => 'Choose \"Copy link\" or share directly';

  @override
  String get importGuideTiktokStep3Desc => 'Either tap \"Copy link\" and paste in Recipe Spellbook, or find Recipe Spellbook in the share options.';

  @override
  String get importGuideTiktokStep3Tip => '\"Copy link\" is often the most reliable method for TikTok.';

  @override
  String get importGuideTiktokStep4Title => 'Find Recipe Spellbook';

  @override
  String get importGuideTiktokStep4Desc => 'Tap More to see all your apps, then find and tap Recipe Spellbook.';

  @override
  String get importGuideTiktokStep5Title => 'Preview & import';

  @override
  String get importGuideTiktokStep5Desc => 'Review the recipe details and tap Import to save it to your cookbook.';

  @override
  String get importGuideYoutubeTitle => 'YouTube';

  @override
  String get importGuideYoutubeSubtitle => 'Import from cooking channels & Shorts';

  @override
  String get importGuideYoutubeStep1Title => 'Find a recipe video';

  @override
  String get importGuideYoutubeStep1Desc => 'Open YouTube and find a cooking video. Works with regular videos, Shorts, and livestream replays.';

  @override
  String get importGuideYoutubeStep2Title => 'Tap Share';

  @override
  String get importGuideYoutubeStep2Desc => 'Tap the Share button below the video title.';

  @override
  String get importGuideYoutubeStep3Title => 'Copy link or share to app';

  @override
  String get importGuideYoutubeStep3Desc => 'Tap \"Copy link\" or find Recipe Spellbook in the share sheet.';

  @override
  String get importGuideYoutubeStep3Tip => 'Many YouTube creators put the full recipe in the video description — this makes extraction more accurate.';

  @override
  String get importGuideYoutubeStep4Title => 'Preview & import';

  @override
  String get importGuideYoutubeStep4Desc => 'Review the extracted recipe and tap Import to save it to your cookbook.';

  @override
  String get importGuidePinterestTitle => 'Pinterest';

  @override
  String get importGuidePinterestSubtitle => 'Save pinned recipes to your cookbook';

  @override
  String get importGuidePinterestStep1Title => 'Open a recipe pin';

  @override
  String get importGuidePinterestStep1Desc => 'Tap a recipe pin to open it. Most pins link to the original recipe website.';

  @override
  String get importGuidePinterestStep2Title => 'Tap the source link';

  @override
  String get importGuidePinterestStep2Desc => 'Tap the link at the top or bottom of the pin to visit the original recipe page.';

  @override
  String get importGuidePinterestStep2Tip => 'If the pin doesn\'t have a source link, try the share method below instead.';

  @override
  String get importGuidePinterestStep3Title => 'Share to Recipe Spellbook';

  @override
  String get importGuidePinterestStep3Desc => 'Tap the share button and select Recipe Spellbook from the app list.';

  @override
  String get importGuidePinterestStep4Title => 'Preview & import';

  @override
  String get importGuidePinterestStep4Desc => 'Review the recipe details and tap Import to save it to your cookbook.';

  @override
  String get importGuideWebsiteTitle => 'Any Recipe Website';

  @override
  String get importGuideWebsiteSubtitle => 'AllRecipes, Food Network, BBC, blogs & more';

  @override
  String get importGuideWebsiteStep1Title => 'Open the recipe page';

  @override
  String get importGuideWebsiteStep1Desc => 'Navigate to any recipe on sites like AllRecipes, Food Network, BBC Good Food, Serious Eats, NYT Cooking, or any food blog.';

  @override
  String get importGuideWebsiteStep2Title => 'Copy the URL';

  @override
  String get importGuideWebsiteStep2Desc => 'Tap the address bar and copy the full URL to the recipe.';

  @override
  String get importGuideWebsiteStep3Title => 'Tap the Share button';

  @override
  String get importGuideWebsiteStep3Desc => 'Tap the browser\'s share or More button to see sharing options.';

  @override
  String get importGuideWebsiteStep4Title => 'Choose Recipe Spellbook';

  @override
  String get importGuideWebsiteStep4Desc => 'Find and tap Recipe Spellbook in the app list.';

  @override
  String get importGuideWebsiteStep5Title => 'Preview & import';

  @override
  String get importGuideWebsiteStep5Desc => 'Review the extracted recipe and tap Import to save it to your cookbook.';

  @override
  String get importGuideWebsiteStep5Tip => 'Works with 10,000+ recipe sites. If extraction fails, try the \"From Text\" method.';

  @override
  String get importGuidePhotoTitle => 'Photo / Camera';

  @override
  String get importGuidePhotoSubtitle => 'Scan recipes from books, magazines, or handwritten cards';

  @override
  String get importGuidePhotoStep1Title => 'Photograph the recipe';

  @override
  String get importGuidePhotoStep1Desc => 'Take a clear, well-lit photo of a recipe from a cookbook, magazine page, or handwritten recipe card. Make sure all text is readable.';

  @override
  String get importGuidePhotoStep1Tip => 'For best results: use good lighting, hold steady, and make sure the entire recipe is in frame. Avoid shadows.';

  @override
  String get importGuidePhotoStep2Title => 'Tap + then \"From Photo\"';

  @override
  String get importGuidePhotoStep2Desc => 'Open Recipe Spellbook, tap +, and choose \"From Photo\". Select the photo from your gallery or take a new one.';

  @override
  String get importGuidePhotoStep3Title => 'Select your image';

  @override
  String get importGuidePhotoStep3Desc => 'Pick the recipe image from your gallery.';

  @override
  String get importGuidePhotoStep4Title => 'Review & fix any errors';

  @override
  String get importGuidePhotoStep4Desc => 'Check the extracted recipe. OCR occasionally misreads characters — \"1/2\" might become \"1l2\". Fix any errors and save.';

  @override
  String get importGuidePhotoStep4Tip => 'Handwritten recipes work too, but printed text gives the best results.';

  @override
  String get importGuidePdfTitle => 'PDF Document';

  @override
  String get importGuidePdfSubtitle => 'Import from PDF cookbooks or downloads';

  @override
  String get importGuidePdfStep1Title => 'Have a recipe PDF ready';

  @override
  String get importGuidePdfStep1Desc => 'This works with downloaded recipe PDFs, ebook cookbooks, scanned documents, or PDFs shared via email.';

  @override
  String get importGuidePdfStep2Title => 'Tap + then \"From PDF\"';

  @override
  String get importGuidePdfStep2Desc => 'Open Recipe Spellbook, tap +, choose \"From PDF\", and select your file.';

  @override
  String get importGuidePdfStep3Title => 'Select the recipe page';

  @override
  String get importGuidePdfStep3Desc => 'If the PDF has multiple pages, choose which page contains the recipe you want to import.';

  @override
  String get importGuidePdfStep4Title => 'Review & save';

  @override
  String get importGuidePdfStep4Desc => 'The recipe is extracted from the PDF. Review the ingredients and steps, then save to your cookbook.';

  @override
  String get importGuideTextTitle => 'Text / Paste';

  @override
  String get importGuideTextSubtitle => 'Paste a recipe from messages, email, or notes';

  @override
  String get importGuideTextStep1Title => 'Copy recipe text';

  @override
  String get importGuideTextStep1Desc => 'Copy the recipe text from a text message, email, notes app, WhatsApp, or anywhere else.';

  @override
  String get importGuideTextStep2Title => 'Tap + then \"From Text\"';

  @override
  String get importGuideTextStep2Desc => 'Open Recipe Spellbook, tap +, and choose \"From Text\".';

  @override
  String get importGuideTextStep3Title => 'Paste your recipe';

  @override
  String get importGuideTextStep3Desc => 'Paste the copied text into the text field. The AI will automatically separate the title, ingredients, and steps.';

  @override
  String get importGuideTextStep3Tip => 'This works even with unformatted text — the AI is smart about parsing ingredient amounts and step instructions.';

  @override
  String get importGuideTextStep4Title => 'Review & save';

  @override
  String get importGuideTextStep4Desc => 'Check the parsed recipe, make any adjustments, and save.';

  @override
  String get importGuideAiTitle => 'AI (ChatGPT, Claude, etc.)';

  @override
  String get importGuideAiSubtitle => 'Generate recipes with AI and import them instantly';

  @override
  String get importGuideAiStep1Title => 'Open AI Import';

  @override
  String get importGuideAiStep1Desc => 'Go to Home, tap + to add a recipe, choose Import, then tap the AI button.';

  @override
  String get importGuideAiStep2Title => 'Copy the prompt';

  @override
  String get importGuideAiStep2Desc => 'Tap the copy prompt button. Then open your favorite AI — ChatGPT, Claude, Gemini, or any other — and paste the prompt.';

  @override
  String get importGuideAiStep3Title => 'Copy the AI\'s response';

  @override
  String get importGuideAiStep3Desc => 'The AI will generate a recipe in JSON format. Copy the entire response.';

  @override
  String get importGuideAiStep4Title => 'Paste into Recipe Spellbook';

  @override
  String get importGuideAiStep4Desc => 'Go back to Recipe Spellbook, tap the paste button, then tap Preview to see the parsed recipe.';

  @override
  String get importGuideAiStep5Title => 'Preview & import';

  @override
  String get importGuideAiStep5Desc => 'Check that everything looks correct, then tap Import to save the recipe to your cookbook.';

  @override
  String get importGuideOtherAppsTitle => 'Other Recipe Apps';

  @override
  String get importGuideOtherAppsSubtitle => 'Mealime, CopyMeThat, AnyList, Cookmate, etc.';

  @override
  String get importGuideOtherAppsStep1Title => 'Export from your current app';

  @override
  String get importGuideOtherAppsStep1Desc => 'Most recipe apps support exporting to JSON, HTML, or text. Check their Settings > Export or Backup section.';

  @override
  String get importGuideOtherAppsStep1Tip => 'Common formats: JSON (best), HTML, PDF, or plain text. JSON preserves the most data.';

  @override
  String get importGuideOtherAppsStep2Title => 'Get the file on your device';

  @override
  String get importGuideOtherAppsStep2Desc => 'Save or transfer the exported file to your phone using email, cloud storage, or a file transfer method.';

  @override
  String get importGuideOtherAppsStep3Title => 'Import the file';

  @override
  String get importGuideOtherAppsStep3Desc => 'In Recipe Spellbook, open the main menu and tap Add Recipe → Import → File, then select the exported file. The app handles JSON, HTML, and common recipe formats.';

  @override
  String get importGuideOtherAppsStep4Title => 'Check your recipes';

  @override
  String get importGuideOtherAppsStep4Desc => 'Imported recipes appear in your default cookbook. You can reorganize them into different cookbooks afterward.';

  @override
  String get importGuideDeviceTransferTitle => 'Device Transfer';

  @override
  String get importGuideDeviceTransferSubtitle => 'Move recipes between phones without an account';

  @override
  String get importGuideDeviceTransferStep1Title => 'Open Transfer on the OLD device';

  @override
  String get importGuideDeviceTransferStep1Desc => 'On your old phone, open Recipe Spellbook and go to Menu > Device Transfer > Send.';

  @override
  String get importGuideDeviceTransferStep2Title => 'Get the transfer code';

  @override
  String get importGuideDeviceTransferStep2Desc => 'A 6-character code is generated. This code is valid for 1 hour.';

  @override
  String get importGuideDeviceTransferStep3Title => 'Enter code on NEW device';

  @override
  String get importGuideDeviceTransferStep3Desc => 'On your new phone, install Recipe Spellbook and go to Menu > Device Transfer > Receive. Enter the code.';

  @override
  String get importGuideDeviceTransferStep4Title => 'Recipes transferred!';

  @override
  String get importGuideDeviceTransferStep4Desc => 'All your recipes, cookbooks, shopping lists, and meal plans are transferred to the new device.';

  @override
  String get importGuideDeviceTransferStep4Tip => 'Have a paid account? Just sign in on the new device and everything syncs automatically.';

  @override
  String get faqTitle => 'FAQs';

  @override
  String get faqHeroTitle => 'Frequently asked questions';

  @override
  String get faqHeroSubtitle => 'Find answers and step-by-step guides for common features.';

  @override
  String get faqHowToGuides => 'How-to Guides';

  @override
  String get faqCommonQuestions => 'Common Questions';

  @override
  String get faqSeeHowTo => 'See how-to guide';

  @override
  String faqStepsCount(int count) {
    return '$count steps';
  }

  @override
  String get faqAddHeadersTitle => 'How to add headers';

  @override
  String get faqAddHeadersSubtitle => 'Organize your recipe ingredients and steps into sections';

  @override
  String get faqAddHeadersStep1Title => 'Open the recipe editor';

  @override
  String get faqAddHeadersStep1Desc => 'Open a recipe and tap the edit icon.';

  @override
  String get faqAddHeadersStep2Title => 'Add a header';

  @override
  String get faqAddHeadersStep2Desc => 'Tap the \'Add Header\' button to insert a section header.';

  @override
  String get faqAddHeadersStep3Title => 'Open the header menu';

  @override
  String get faqAddHeadersStep3Desc => 'Tap the three dots (⋮) next to the header for more options.';

  @override
  String get faqAddHeadersStep4Title => 'Reorder your headers';

  @override
  String get faqAddHeadersStep4Desc => 'Tap Sort Order to rearrange. Drag the ≡ handle to move headers up or down.';

  @override
  String get faqAddHeadersStep4Tip => 'You can drag headers by holding the ≡ (two lines) handle on the left side.';

  @override
  String get faqAddHeadersStep5Title => 'Save your changes';

  @override
  String get faqAddHeadersStep5Desc => 'Tap the save button to keep your new headers.';

  @override
  String get faqAddHeadersStep6Title => 'Done!';

  @override
  String get faqAddHeadersStep6Desc => 'Your recipe now has organized sections with headers.';

  @override
  String get faqAddSublinkedTitle => 'How to add sublinked recipes';

  @override
  String get faqAddSublinkedSubtitle => 'Link related recipes together for quick access';

  @override
  String get faqAddSublinkedStep1Title => 'Open the recipe editor';

  @override
  String get faqAddSublinkedStep1Desc => 'Open a recipe and tap the edit icon.';

  @override
  String get faqAddSublinkedStep2Title => 'Open the menu';

  @override
  String get faqAddSublinkedStep2Desc => 'Tap the three dots (⋮) in the edit screen.';

  @override
  String get faqAddSublinkedStep3Title => 'Tap Link Recipe';

  @override
  String get faqAddSublinkedStep3Desc => 'Select \'Link Recipe\' from the menu.';

  @override
  String get faqAddSublinkedStep4Title => 'Choose a recipe to link';

  @override
  String get faqAddSublinkedStep4Desc => 'Tap the link icon next to the recipe you want to connect (e.g., Pizza Dough).';

  @override
  String get faqAddSublinkedStep5Title => 'Save your changes';

  @override
  String get faqAddSublinkedStep5Desc => 'Tap the save icon to keep the linked recipe.';

  @override
  String get faqAddSublinkedStep6Title => 'Done!';

  @override
  String get faqAddSublinkedStep6Desc => 'The linked recipe now appears in your recipe, ready to tap and view.';

  @override
  String get faqWhatAreHeadersTitle => 'What are headers?';

  @override
  String get faqWhatAreHeadersSubtitle => 'Organize recipes into sections';

  @override
  String get faqWhatAreHeadersAnswer => 'Headers let you divide your recipe ingredients and steps into sections. For example, you could have separate sections for \'Sauce\', \'Dough\', and \'Topping\' in a pizza recipe. They make long recipes much easier to follow.';

  @override
  String get faqWhatAreSublinkedTitle => 'What are sublinked recipes?';

  @override
  String get faqWhatAreSublinkedSubtitle => 'Connect related recipes together';

  @override
  String get faqWhatAreSublinkedAnswer => 'Sublinked recipes let you connect related recipes together. For example, a Margherita Pizza recipe can link to your Pizza Dough recipe. When viewing the main recipe, you can tap the linked recipe to jump straight to it — no searching needed.';

  @override
  String get faqMacroCalcTitle => 'How to use the Macro Calculator';

  @override
  String get faqMacroCalcSubtitle => 'Auto-calculate calories and macros for any recipe';

  @override
  String get faqMacroCalcStep1Title => 'Open a recipe';

  @override
  String get faqMacroCalcStep1Desc => 'Open any recipe to view its details.';

  @override
  String get faqMacroCalcStep2Title => 'Find the Nutrition section';

  @override
  String get faqMacroCalcStep2Desc => 'Scroll to the bottom of the recipe. If no nutrition data exists yet, you\'ll see an empty state — tap it to start the calculator.';

  @override
  String get faqMacroCalcStep3Title => 'View the calculator';

  @override
  String get faqMacroCalcStep3Desc => 'The calculator automatically matches your ingredients to the USDA food database and shows the match rate, calories, and macro breakdown.';

  @override
  String get faqMacroCalcStep4Title => 'Enter manually';

  @override
  String get faqMacroCalcStep4Desc => 'Tap \'Enter Manually\' to edit nutrition values by hand if you prefer to input your own data instead of using the auto-calculated results.';

  @override
  String get faqMacroCalcStep5Title => 'Review ingredient matches';

  @override
  String get faqMacroCalcStep5Desc => 'Scroll down to see each ingredient matched to a USDA food item. Sublinked recipes (like Pizza Dough) use their own stored nutrition instead.';

  @override
  String get faqMacroCalcStep5Tip => 'Not sure what a sublinked recipe is? Check out the \'What are sublinked recipes?\' section in the FAQ!';

  @override
  String get faqMacroCalcStep6Title => 'Browse the USDA database';

  @override
  String get faqMacroCalcStep6Desc => 'Tap any ingredient to search the USDA database for a better match. You can pick from thousands of verified food items.';

  @override
  String get faqMacroCalcStep7Title => 'Linked recipe nutrition';

  @override
  String get faqMacroCalcStep7Desc => 'Ingredients linked to other recipes show the linked recipe\'s nutrition data. You can adjust the scale to use a fraction of the linked recipe.';

  @override
  String get faqMacroCalcStep8Title => 'Save your results';

  @override
  String get faqMacroCalcStep8Desc => 'Tap Save to store the nutrition data. The macros will now appear on your recipe with charts and detailed breakdowns per serving.';

  @override
  String get faqMacroCalcStep9Title => 'Customize the display';

  @override
  String get faqMacroCalcStep9Desc => 'Go to Settings > Nutrition Display to choose which nutrients to show and how the charts are displayed.';

  @override
  String get faqWhatIsMacroCalcTitle => 'What is the Macro Calculator?';

  @override
  String get faqWhatIsMacroCalcSubtitle => 'Automatic nutrition estimation for recipes';

  @override
  String get faqWhatIsMacroCalcAnswer => 'The Macro Calculator automatically estimates the nutritional content of your recipes by matching each ingredient to the USDA food database. It calculates calories, protein, carbs, fat, fiber, sugar, sodium, and more — all per serving. You can find it in the Nutrition section of any recipe.';

  @override
  String get faqImportFailedTitle => 'Why did my import fail?';

  @override
  String get faqImportFailedSubtitle => 'Common reasons and fixes';

  @override
  String get faqImportFailedAnswer => 'Imports can fail for a few reasons:\n\n• The website may block automated access — try copying the recipe text and using Text Import instead.\n• The link may have expired or be private — make sure it’s a public link.\n• Some sites use formats that are harder to parse — try the AI import as an alternative.\n• Check your internet connection and try again.';

  @override
  String get faqDeviceTransferTitle => 'Can I import from other devices?';

  @override
  String get faqDeviceTransferSubtitle => 'Transfer recipes between phones and tablets';

  @override
  String get faqDeviceTransferAnswer => 'Yes! Use the Device Transfer feature in Settings > Data > Device Transfer. Generate a code on your old device and enter it on your new one. All your recipes, cookbooks, and images will be transferred.';

  @override
  String get themeFrost => 'Frost';

  @override
  String get themeEmber => 'Ember';

  @override
  String get themeSpring => 'Spring';

  @override
  String get themeAlchemist => 'Alchemist';

  @override
  String get themeMatcha => 'Matcha';

  @override
  String get themeCustom => 'Custom';

  @override
  String get communitySortTopRated => 'Top Rated';

  @override
  String get communityHasImages => 'Has images';

  @override
  String get communityListView => 'List view';

  @override
  String get communityGridView => 'Grid view';

  @override
  String get communityDownloadOptions => 'Download Options';

  @override
  String communityDownloadWithImages(String size) {
    return 'With images ($size)';
  }

  @override
  String communityDownloadImagesIncluded(int count) {
    return '$count photos included';
  }

  @override
  String get communityDownloadTextOnly => 'Text only';

  @override
  String get communityDownloadTextOnlySubtitle => 'Just recipes, no images';

  @override
  String get communityTapToPreview => 'Tap any recipe to preview';

  @override
  String communityImageCountLabel(int count) {
    return '$count photos';
  }

  @override
  String get communityYourRating => 'Your rating';

  @override
  String get communityRateThis => 'Rate this';

  @override
  String communityDownloadingImages(int current, int total) {
    return 'Downloading images... ($current/$total)';
  }

  @override
  String get communityViewFullRecipe => 'View Full Recipe';

  @override
  String communityMoreIngredients(int count) {
    return '+ $count more';
  }

  @override
  String communityStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Steps',
      one: '1 Step',
    );
    return '$_temp0';
  }

  @override
  String get communityNotes => 'Notes';

  @override
  String get communityStatPrep => 'Prep';

  @override
  String get communityStatCook => 'Cook';

  @override
  String get communityStatTotal => 'Total';

  @override
  String get communityStatServings => 'Servings';

  @override
  String communityStepDuration(int minutes) {
    return '$minutes min';
  }

  @override
  String get communityEditPublication => 'Edit Publication';

  @override
  String get communityEditDescription => 'Description';

  @override
  String get communityEditDescriptionHint => 'Add a description...';

  @override
  String get communityEditTags => 'Tags';

  @override
  String get communityEditSuccess => 'Publication updated';

  @override
  String get communityEditFailed => 'Failed to update publication';

  @override
  String get communityNoRatingsYet => 'No ratings yet';

  @override
  String get communityStatusPublished => 'Published';

  @override
  String get communityStatusUnderReview => 'Under Review';

  @override
  String get communityStatusRemoved => 'Removed';

  @override
  String get communityUnderReview => 'This cookbook is under review by our moderation team.';

  @override
  String get communityPublishPreparing => 'Preparing...';

  @override
  String communityPublishUploading(int current, int total) {
    return 'Uploading images ($current/$total)...';
  }

  @override
  String get communityPublishPublishing => 'Publishing...';

  @override
  String get communityPublishBackground => 'You can browse while publishing continues.\nKeep the app open — switching apps may cause uploads to fail.';

  @override
  String get communityPublishDone => 'Published!';

  @override
  String communityPublishImagesSkipped(int count) {
    return '$count images could not be uploaded (upload failed or rejected)';
  }

  @override
  String communityPublishRejected(int count) {
    return '$count images failed to upload';
  }

  @override
  String get communityConfigurePublication => 'Configure Publication';

  @override
  String get communityPublishTitle => 'Title';

  @override
  String get communityPublishTitleHint => 'Cookbook title';

  @override
  String get communityPublishDescription => 'Description';

  @override
  String get communityPublishDescriptionHint => 'Describe your cookbook...';

  @override
  String get communityPublishTags => 'Tags';

  @override
  String get communityPublishIncludeImages => 'Include Images';

  @override
  String get communityPublishIncludeImagesSubtitle => 'Upload recipe photos with the cookbook';

  @override
  String get communityPublishSummary => 'Summary';

  @override
  String communityPublishRecipesSummary(int count) {
    return '$count recipes will be published';
  }

  @override
  String get communityPublishImagesWillUpload => 'Images will be uploaded';

  @override
  String get communityPublishTextOnlyNoImages => 'Text only — no images';

  @override
  String get communityPublishTryAgain => 'Try Again';

  @override
  String communityPublishUploadInProgress(int current, int total) {
    return 'Upload in progress ($current/$total). Wait for it to finish before publishing again.';
  }

  @override
  String get surpriseMeTitle => 'Surprise Me!';

  @override
  String get surpriseMeSubtitle => 'What should I cook?';

  @override
  String get hintNutritionCalculator => 'Did you know? Tap the nutrition icon to auto-calculate nutrition for any recipe.';

  @override
  String get hintCookingScreen => 'Try cooking mode! Tap \'Cook\' on any recipe for hands-free step-by-step instructions.';

  @override
  String get hintIngredientHeaders => 'Tip: Type a line ending with \':\' in ingredients to create a section header.';

  @override
  String get hintImportMethods => 'Import recipes from URLs, photos, PDFs, or even Instagram and TikTok!';

  @override
  String get hintMealPlanAutoFill => 'Drag recipes into your meal plan, or tap a day to pick from your collection.';

  @override
  String get hintRecipeScaling => 'Tap the servings number on any recipe to scale ingredients up or down.';

  @override
  String get hintShoppingListGen => 'Add recipe ingredients to your shopping list with one tap.';

  @override
  String get hintRecipeNotes => 'Add personal notes to any recipe - tips, modifications, or memories.';

  @override
  String get hintCookbookOrganization => 'Create multiple cookbooks to organize your recipes by theme or occasion.';

  @override
  String get hintTagSystem => 'Tag recipes for easy filtering - create custom tags like \'Quick\', \'Favorite\', etc.';

  @override
  String get allergyMyAllergies => 'My Allergies';

  @override
  String get allergyDisabledTab => 'Disabled';

  @override
  String get allergyNoDisabledTitle => 'No Disabled Warnings';

  @override
  String get allergyNoDisabledSubtitle => 'When you dismiss allergy warnings on recipes, they will appear here so you can restore them later.';

  @override
  String get allergyDisabledInfo => 'These recipes have had their allergy warnings disabled. Tap to restore warnings.';

  @override
  String trashRestoredMessage(String title) {
    return '\"$title\" restored';
  }

  @override
  String get nutrientCalories => 'Calories';

  @override
  String get nutrientTotalFat => 'Total Fat';

  @override
  String get nutrientSaturatedFat => 'Saturated Fat';

  @override
  String get nutrientTransFat => 'Trans Fat';

  @override
  String get nutrientMonounsaturatedFat => 'Monounsaturated Fat';

  @override
  String get nutrientPolyunsaturatedFat => 'Polyunsaturated Fat';

  @override
  String get nutrientCarbohydrates => 'Carbohydrates';

  @override
  String get nutrientFiber => 'Fiber';

  @override
  String get nutrientSugars => 'Sugars';

  @override
  String get nutrientProtein => 'Protein';

  @override
  String get nutrientCholesterol => 'Cholesterol';

  @override
  String get nutrientSodium => 'Sodium';

  @override
  String get nutrientPotassium => 'Potassium';

  @override
  String get nutrientCalcium => 'Calcium';

  @override
  String get nutrientIron => 'Iron';

  @override
  String get nutrientMagnesium => 'Magnesium';

  @override
  String get nutrientPhosphorus => 'Phosphorus';

  @override
  String get nutrientZinc => 'Zinc';

  @override
  String get nutrientCopper => 'Copper';

  @override
  String get nutrientManganese => 'Manganese';

  @override
  String get nutrientSelenium => 'Selenium';

  @override
  String get nutrientVitaminA => 'Vitamin A';

  @override
  String get nutrientVitaminC => 'Vitamin C';

  @override
  String get nutrientVitaminD => 'Vitamin D';

  @override
  String get nutrientVitaminE => 'Vitamin E';

  @override
  String get nutrientVitaminK => 'Vitamin K';

  @override
  String get nutrientThiaminB1 => 'Thiamin (B1)';

  @override
  String get nutrientRiboflavinB2 => 'Riboflavin (B2)';

  @override
  String get nutrientNiacinB3 => 'Niacin (B3)';

  @override
  String get nutrientPantothenicAcidB5 => 'Pantothenic Acid (B5)';

  @override
  String get nutrientVitaminB6 => 'Vitamin B6';

  @override
  String get nutrientVitaminB12 => 'Vitamin B12';

  @override
  String get nutrientFolate => 'Folate';

  @override
  String get nutrientCholine => 'Choline';

  @override
  String get nutrientCategoryMacronutrients => 'Macronutrients';

  @override
  String get nutrientCategoryMinerals => 'Minerals';

  @override
  String get nutrientCategoryVitamins => 'Vitamins';

  @override
  String get nutrientCarbs => 'Carbs';

  @override
  String get nutrientFat => 'Fat';

  @override
  String nutritionKcalPerServing(int count) {
    return '$count kcal per serving';
  }

  @override
  String nutritionKcalTotal(int count) {
    return '$count kcal total';
  }

  @override
  String get shareShoppingList => 'Share Shopping List';

  @override
  String get shareOneTimeLink => 'One-Time Link';

  @override
  String get shareOneTimeLinkSubtitle => 'Free • 24h expiry • View/download only';

  @override
  String get shareGenerateLink => 'Generate Link';

  @override
  String get shareFamilyShare => 'Family Share';

  @override
  String get shareFamilySyncSubtitle => 'Real-time sync • Per-member permissions';

  @override
  String get shareFamilyCreateJoin => 'Create or join a family to share';

  @override
  String get shareFamilyRequiresCloudSync => 'Requires Cloud Sync subscription';

  @override
  String get shareFamilyUpgradeMessage => 'Upgrade to Cloud Sync to share cookbooks and lists with your family in real-time.';

  @override
  String get shareFamilySignIn => 'Sign in to use family sharing';

  @override
  String get shareFamilySetupInSettings => 'Create or join a family in Settings → Family Sharing';

  @override
  String get shareSharedWith => 'Shared with';

  @override
  String get shareRevoked => 'Share revoked';

  @override
  String get shareSignInRequired => 'Sign in to create share links';

  @override
  String get shareCreateFailed => 'Failed to create link';

  @override
  String get shareNoFamilyMembers => 'No other family members to share with';

  @override
  String get shareAddFamilyMembers => 'Add family members';

  @override
  String get shareWith => 'Share with';

  @override
  String shareSharedWithMember(String name) {
    return 'Shared with $name';
  }

  @override
  String get shareShareFailed => 'Failed to share';

  @override
  String get shareLinkCopied => 'Link copied!';

  @override
  String shareLinkExpiresIn(int hours) {
    return 'Expires in ${hours}h';
  }

  @override
  String get shareRevoke => 'Revoke';

  @override
  String get shareUpgrade => 'Upgrade';

  @override
  String get sharePermReadOnly => 'Read Only';

  @override
  String get sharePermAddOnly => 'Add Only';

  @override
  String get sharePermFullEdit => 'Full Edit';

  @override
  String get sharePermFullAccess => 'Full Access';

  @override
  String get sharePermViewRecipes => 'Can view recipes';

  @override
  String get sharePermAddRecipes => 'Can add new recipes';

  @override
  String get sharePermEditRecipes => 'Can edit any recipe';

  @override
  String get sharePermViewItems => 'Can view items';

  @override
  String get sharePermAddItems => 'Can add items, edit own';

  @override
  String get sharePermEditItems => 'Can edit & delete items';

  @override
  String get shareUnknownMember => 'Unknown';

  @override
  String get subscriptionTitle => 'Subscription';

  @override
  String get subscriptionUpgradeToPro => 'Upgrade to Pro';

  @override
  String get subscriptionUnlockFeatures => 'Unlock cloud sync, smart import, and more.';

  @override
  String get subscriptionViewPlans => 'View Plans';

  @override
  String get subscriptionRestored => 'Purchases restored successfully!';

  @override
  String get subscriptionNoPurchases => 'No previous purchases found.';

  @override
  String subscriptionRestoreFailed(String error) {
    return 'Restore failed: $error';
  }

  @override
  String get subscriptionRestorePurchases => 'Restore purchases';

  @override
  String subscriptionCancelledUntil(String date) {
    return 'Cancelled — access until $date';
  }

  @override
  String get subscriptionRenews => 'Renews';

  @override
  String get subscriptionPlan => 'Plan';

  @override
  String get subscriptionLifetime => 'Lifetime — never expires';

  @override
  String get subscriptionManage => 'Manage subscription';

  @override
  String get subscriptionUnknownDate => 'Unknown';

  @override
  String get subscriptionUpgradeToUnlock => 'Upgrade to Pro to unlock';

  @override
  String get subscriptionProBadge => 'PRO';

  @override
  String get customThemeTitle => 'Custom Theme';

  @override
  String get customThemeColors => 'Colors';

  @override
  String get customThemeBackground => 'Background';

  @override
  String get customThemeBackgroundDesc => 'App background, scaffold';

  @override
  String get customThemePrimary => 'Primary';

  @override
  String get customThemePrimaryDesc => 'Buttons, highlights, app bar';

  @override
  String get customThemeAccent => 'Accent';

  @override
  String get customThemeAccentDesc => 'FAB, switches, secondary highlights';

  @override
  String get customThemeStartFromPreset => 'Start from a preset';

  @override
  String get customThemeLightMode => 'Light';

  @override
  String get customThemeDarkMode => 'Dark';

  @override
  String customThemeLinkedOverlay(String mode) {
    return 'Colors are auto-generated from your $mode theme';
  }

  @override
  String get customThemeUnlockButton => 'Customize colors';

  @override
  String customThemeLinkButton(String mode) {
    return 'Link to $mode';
  }

  @override
  String get customThemeLivePreview => 'Live Preview';

  @override
  String get settingsUserFallback => 'User';

  @override
  String get settingsManageSection => 'Manage';

  @override
  String get settingsExportNone => 'None Selected';

  @override
  String get settingsExportPartial => 'Partial Backup';

  @override
  String get settingsSystemLanguage => 'System';

  @override
  String get tierFamily => 'FAMILY';

  @override
  String get tierCreator => 'CREATOR';

  @override
  String get tierFreeName => 'Free';

  @override
  String get tierPremiumName => 'Premium';

  @override
  String get tierCloudSyncName => 'Cloud Sync';

  @override
  String get tierCloudSyncFamilyName => 'Cloud Sync Family';

  @override
  String get tierCreatorName => 'Creator';

  @override
  String get nutritionEstimated => 'Estimated values';

  @override
  String get nutritionTipMatch => 'Tap any ingredient to change its USDA food match';

  @override
  String get nutritionTipManual => 'Enter exact nutrition values if you know them';

  @override
  String get nutritionTipSpecific => 'Choose specific types (e.g., \"all-purpose flour\" not just \"flour\")';

  @override
  String get nutritionTipSaved => 'Your corrections are saved for future recipes';

  @override
  String get nutritionGotIt => 'Got it';

  @override
  String get nutritionScaleMultiplier => 'Scale multiplier';

  @override
  String get nutritionScaleHelper => '1.0 = full recipe';

  @override
  String nutritionOpenRecipe(String title) {
    return 'Open $title';
  }

  @override
  String get nutrientCal => 'Cal';

  @override
  String get nutrientSugar => 'Sugar';

  @override
  String get appearanceCustomThemeRequiresPremium => 'Custom theme requires Premium';

  @override
  String get appearancePremiumBadge => 'Premium';

  @override
  String get substitutionsAll => 'All';

  @override
  String substitutionsCount(int count, String category) {
    return '$count substitutes • $category';
  }

  @override
  String get colorPickerTitle => 'Pick a color';

  @override
  String get colorPickerHex => 'Hex';

  @override
  String get colorPickerSelect => 'Select';

  @override
  String get scanSelectPages => 'Select multiple pages';

  @override
  String get scanNoTextPdf => 'No text found in PDF. Try using a clearer scan or the Text paste option instead.';

  @override
  String scanLittleTextPdf(int count) {
    return 'Very little text detected in PDF ($count characters). The scan may be too blurry. Try a higher quality PDF, or use the Text paste option instead.';
  }

  @override
  String get scanNoTextImage => 'No text found in image. Try taking the photo in better lighting, or use the Text paste option instead.';

  @override
  String scanLittleTextImage(int count) {
    return 'Very little text detected ($count characters). Try a clearer photo with better lighting, or use the Text paste option instead.';
  }

  @override
  String scanProgress(int current, int total) {
    return 'Scanning page $current of $total...';
  }

  @override
  String get communityTagHint => 'Add custom tag...';

  @override
  String get tagPickerOrganize => 'Tags help you organize your recipes';

  @override
  String get tagPickerLoadDefaults => 'Load Default Tags';

  @override
  String get tagPickerExampleHint => 'e.g., Date Night';

  @override
  String drawerProTier(String tier) {
    return 'Pro · $tier';
  }

  @override
  String get accountStoreFallback => 'Store';

  @override
  String get communityUnpublishDialogTitle => 'Unpublish this cookbook?';

  @override
  String get communityUnpublishDialogMessage => 'It will be removed from the community. Your recipes are unaffected.';

  @override
  String get communityPublishAnotherCookbook => '+ Publish another cookbook';

  @override
  String get communityShareMoreWithCommunity => 'Share more with the community';

  @override
  String get communityUploading => 'Uploading...';

  @override
  String get communityStatRecipes => 'recipes';

  @override
  String get communityStatDownloads => 'downloads';

  @override
  String get communityStatRating => 'rating';

  @override
  String get communityRemovedByModerator => 'This cookbook was removed by a moderator.';

  @override
  String get communityBrowseRecipes => 'Recipes';

  @override
  String get communityBrowseCookbooks => 'Cookbooks';

  @override
  String get communityNoRecipesYet => 'No community recipes yet';

  @override
  String get communityTryDifferentSearch => 'Try a different search term or clear your filters';

  @override
  String get communityBeFirstToShare => 'Be the first to share a cookbook with the community!';

  @override
  String get communityPublishToShare => 'Publish a cookbook to share your recipes with everyone!';

  @override
  String communityFromCookbook(String name) {
    return 'from $name';
  }

  @override
  String communityIngredientsCount(int count) {
    return '$count ingredients';
  }

  @override
  String communitySaveRecipeTo(String title) {
    return 'Save \"$title\" to...';
  }

  @override
  String get communityNewCookbook => 'New Cookbook';

  @override
  String get communityExistingCookbook => 'Existing Cookbook';

  @override
  String get communityAddToExistingCookbook => 'Add to one of your cookbooks';

  @override
  String get communityChooseCookbook => 'Choose Cookbook';

  @override
  String get communityNoCookbooksYetSaveNew => 'No cookbooks yet. Recipes will be saved to a new cookbook.';

  @override
  String get communityCreateCookbookFirstToSave => 'Create a cookbook first to save recipes';

  @override
  String get communitySaveTo => 'Save to:';

  @override
  String communitySaveRecipeCount(int count) {
    return 'Save $count Recipes';
  }

  @override
  String get communityFailedToSaveRating => 'Failed to save rating. Please try again.';

  @override
  String get communityDownloadingCookbook => 'Downloading cookbook...';

  @override
  String get communitySavingRecipes => 'Saving recipes...';

  @override
  String communityPartialDownloadSuccess(int count, String title) {
    return '$count recipes saved from \"$title\"';
  }

  @override
  String get communityCannotReportOwn => 'You cannot report your own publication';

  @override
  String get communityEditCookbook => 'Edit Cookbook';

  @override
  String get communityEditTitle => 'Title';

  @override
  String get communityEditDescriptionLabel => 'Description';

  @override
  String get communityEditTagsLabel => 'Tags';

  @override
  String get communityCookbookUpdated => 'Cookbook updated';

  @override
  String get communityFailedToUpdate => 'Failed to update';

  @override
  String get communitySaveChanges => 'Save Changes';

  @override
  String get communityEditTooltip => 'Edit';

  @override
  String get communitySelectAllRecipes => 'Select All';

  @override
  String get communityDeselectAllRecipes => 'Deselect All';

  @override
  String communitySelectedOfTotal(int selected, int total) {
    return '$selected of $total selected';
  }

  @override
  String communityDownloadRecipes(int count) {
    return 'Download $count Recipes';
  }

  @override
  String get communityNotCurrentlyRated => 'Not currently rated';

  @override
  String get communityCannotRateOwnCookbook => 'You cannot rate your own cookbook';

  @override
  String get communitySelectIndividualRecipes => 'Select Individual Recipes';

  @override
  String communityWithImages(String size) {
    return '$size with images';
  }

  @override
  String get communitySaveRecipe => 'Save Recipe';

  @override
  String get communityNoCookbooksYetCreate => 'No cookbooks yet';

  @override
  String get communityCreateCookbookFirst => 'Create a cookbook first';

  @override
  String get communitySavingRecipe => 'Saving recipe...';

  @override
  String communityRecipeSaved(String title) {
    return '\"$title\" saved!';
  }

  @override
  String communityFailedToSave(String error) {
    return 'Failed to save: $error';
  }

  @override
  String get communitySaveToMyCookbooks => 'Save to My Cookbooks';

  @override
  String get communityViewCookbook => 'View Cookbook';

  @override
  String get communityPublishInProgress => 'Publishing in progress — cancel the upload first';

  @override
  String get communityUnknownError => 'Unknown error';

  @override
  String get communityUploadCancelled => 'Upload cancelled';

  @override
  String get communityCancelUpload => 'Cancel Upload';

  @override
  String get communityCancelling => 'Cancelling...';

  @override
  String get communityPublishingFailed => 'Publishing failed';

  @override
  String communityTagsSummary(int count) {
    return '$count tags';
  }

  @override
  String get creatorNotFound => 'Creator not found';

  @override
  String creatorMemberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get creatorStatRecipes => 'Recipes';

  @override
  String get creatorStatCookbooks => 'Cookbooks';

  @override
  String get creatorStatDownloads => 'Downloads';

  @override
  String get creatorStatAvgRating => 'Avg Rating';

  @override
  String get creatorPublishedCookbooks => 'Published Cookbooks';

  @override
  String get creatorNoCookbooksYet => 'No published cookbooks yet';

  @override
  String creatorRecipesCount(int count) {
    return '$count recipes';
  }

  @override
  String get follow => 'Follow';

  @override
  String get following => 'Following';

  @override
  String get unfollow => 'Unfollow';

  @override
  String get followers => 'Followers';

  @override
  String get followingLabel => 'Following';

  @override
  String get cannotFollowSelf => 'You cannot follow yourself';

  @override
  String get paywallUpgradeTitle => 'Upgrade Recipe Spellbook';

  @override
  String get paywallSubtitle => 'Your recipes on every device.\nForever.';

  @override
  String get paywallPremiumTitle => 'Premium';

  @override
  String get paywallFamilyTitle => 'Family';

  @override
  String get paywallPremiumFeature1 => 'Cloud sync across all devices';

  @override
  String get paywallPremiumFeature2 => 'Step-by-step photos';

  @override
  String get paywallPremiumFeature3 => 'Automatic backups';

  @override
  String get paywallFamilyFeature1 => 'Everything in Premium';

  @override
  String get paywallFamilyFeature2 => 'Up to 5 family members sync together';

  @override
  String get paywallFamilyFeature3 => 'Shared cookbooks & shopping lists';

  @override
  String get paywallValueProp => 'Most recipe apps charge \$5–10/month. This isn\'t that.';

  @override
  String paywallGetPlan(String planName, String planPrice) {
    return 'Get $planName — $planPrice';
  }

  @override
  String get paywallOneTimePurchase => 'One-time purchase · No subscription · Yours forever';

  @override
  String get paywallRestorePurchases => 'Restore purchases';

  @override
  String get paywallCompleteYourPurchase => 'Complete Your Purchase';

  @override
  String get paywallCompleteMessage => 'After completing your purchase, tap \"Refresh\" below to activate it.';

  @override
  String get paywallRefresh => 'Refresh';

  @override
  String get paywallYoureAllSet => 'You\'re all set!';

  @override
  String get paywallPurchaseNotDetected => 'Purchase not detected yet — try refreshing again.';

  @override
  String get paywallWebComingSoon => 'Web Purchases Coming Soon';

  @override
  String get paywallWebMessage => 'In the meantime, upgrade on Android or iOS and it syncs everywhere.';

  @override
  String get paywallFreeLabel => 'Free';

  @override
  String get paywallPremiumLabel => 'Premium';

  @override
  String get paywallFamilyLabel => 'Family';

  @override
  String get paywallUnlimitedRecipes => 'Unlimited recipes';

  @override
  String get paywallCloudSync => 'Cloud sync';

  @override
  String get paywallFamilySharing => 'Family sharing';

  @override
  String get adminModerationPanel => 'Moderation Panel';

  @override
  String get adminPendingReview => 'Pending Review';

  @override
  String get adminPendingFlags => 'Pending Flags';

  @override
  String get adminPendingReports => 'Pending Reports';

  @override
  String get adminUserReports => 'User Reports';

  @override
  String get adminAllClear => 'All clear!';

  @override
  String get adminNoPendingItems => 'No pending items to review.';

  @override
  String get adminFailedToApprove => 'Failed to approve';

  @override
  String get adminFailedToRemove => 'Failed to remove';

  @override
  String get adminFlagApproved => 'Flag approved (publication removed)';

  @override
  String get adminFailedToApproveFlag => 'Failed to approve flag';

  @override
  String get adminFlagRejected => 'Flag rejected (publication kept)';

  @override
  String get adminFailedToRejectFlag => 'Failed to reject flag';

  @override
  String get adminContentRemovedResolved => 'Content removed & report resolved';

  @override
  String get adminReportDismissed => 'Report dismissed';

  @override
  String get adminFailedToResolveReport => 'Failed to resolve report';

  @override
  String adminByPublisher(String name, int count) {
    return 'By $name · $count recipes';
  }

  @override
  String get adminApprove => 'Approve';

  @override
  String get adminRemove => 'Remove';

  @override
  String adminReportedBy(String name) {
    return 'Reported by: $name';
  }

  @override
  String adminReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get adminRemoveContent => 'Remove Content';

  @override
  String get adminDismissReport => 'Dismiss Report';

  @override
  String get adminDismissFlag => 'Dismiss Flag';

  @override
  String get accountProfileUpdated => 'Profile updated';

  @override
  String get accountProfileUpdateFailed => 'Failed to update profile';

  @override
  String get accountProfilePictureUpdated => 'Profile picture updated';

  @override
  String get accountProfilePictureUpdateFailed => 'Failed to update profile picture';

  @override
  String get accountFailedToUploadImage => 'Failed to upload image';

  @override
  String get accountDisplayNameHint => 'Display name';

  @override
  String get menuDrawerYourStuff => 'Your Stuff';

  @override
  String get menuDrawerOrganize => 'Organize your recipe collections';

  @override
  String get menuDrawerImportSubtitle => 'From any URL, photo or file';

  @override
  String get menuDrawerTransferSubtitle => 'Move recipes between devices';

  @override
  String get menuDrawerApp => 'App';

  @override
  String get menuDrawerSettingsSubtitle => 'Theme, language & preferences';

  @override
  String menuDrawerCouldNotOpenUrl(String url) {
    return 'Could not open $url';
  }

  @override
  String menuDrawerCouldNotOpenLink(String error) {
    return 'Could not open link: $error';
  }

  @override
  String get menuDrawerCouldNotOpenEmail => 'Could not open email client';

  @override
  String menuDrawerCouldNotOpenEmailError(String error) {
    return 'Could not open email: $error';
  }

  @override
  String get menuDrawerGuest => 'Guest';

  @override
  String get menuDrawerCommunity => 'COMMUNITY';

  @override
  String get menuDrawerPublishToBuildStats => 'Publish a cookbook to start building your stats here';

  @override
  String get menuDrawerRecipesUploaded => 'recipes\nuploaded';

  @override
  String get menuDrawerDownloads => 'downloads';

  @override
  String get menuDrawerRating => 'rating';

  @override
  String get recipeListCopyToCookbook => 'Copy to Cookbook';

  @override
  String get recipeListMoveToCookbook => 'Move to Cookbook';

  @override
  String recipeListCopyingRecipes(int count) {
    return 'Copying $count recipes...';
  }

  @override
  String recipeListMovingRecipes(int count) {
    return 'Moving $count recipes...';
  }

  @override
  String get recipeListCreateAnotherFirst => 'Create another cookbook first';

  @override
  String get recipeListSortNewest => 'Newest';

  @override
  String get recipeListSortOldest => 'Oldest';

  @override
  String get recipeListSortRating => 'Rating';

  @override
  String get recipeListSortQuickest => 'Quickest';

  @override
  String get recipeListSizeSmall => 'Small';

  @override
  String get recipeListSizeMedium => 'Medium';

  @override
  String get recipeListSizeLarge => 'Large';

  @override
  String get recipeListPinned => 'Pinned';

  @override
  String get recipeListDeselectAll => 'Deselect all';

  @override
  String get recipeListSelectAll => 'Select all';

  @override
  String get plannerPreviousWeek => 'Previous week';

  @override
  String get plannerNextWeek => 'Next week';

  @override
  String get plannerMoreOptions => 'More options';

  @override
  String get homeScreenSwitchCookbook => 'Switch Cookbook';

  @override
  String get homeScreenNewCookbook => 'New Cookbook';

  @override
  String get shareViewerSharedRecipe => 'Shared Recipe';

  @override
  String get shareViewerGoHome => 'Go Home';

  @override
  String shareViewerSharedBy(String name) {
    return 'Shared by $name';
  }

  @override
  String shareViewerExpires(String date) {
    return 'Expires: $date';
  }

  @override
  String get importIssues => 'Import Issues';

  @override
  String trashPermanentlyDeleteConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recipes',
      one: 'recipe',
    );
    return 'Permanently delete $count $_temp0? This cannot be undone.';
  }

  @override
  String trashDeletingRecipes(int count) {
    return 'Deleting $count recipes...';
  }

  @override
  String get trashDeletingAllRecipes => 'Deleting recipes...';

  @override
  String cookbooksError(String error) {
    return 'Error: $error';
  }

  @override
  String get cookbooksShareFromApp => 'Shared from Recipe Spellbook';

  @override
  String get cookbooksPublishFailed => 'Publish failed';

  @override
  String get displayName => 'Display Name';

  @override
  String get editDisplayName => 'Edit Display Name';

  @override
  String get displayNameHelper => 'Used on your profile and in the community.';

  @override
  String get saveName => 'Save Name';

  @override
  String get nameContainsUnsupported => 'Name contains unsupported characters';

  @override
  String get nameTooShort => 'Name must be at least 2 characters';

  @override
  String get communitySection => 'COMMUNITY';

  @override
  String get subscriptionSection => 'SUBSCRIPTION';

  @override
  String get integrationsSection => 'INTEGRATIONS';

  @override
  String get dangerZoneSection => 'DANGER ZONE';

  @override
  String get unlockPremium => 'Unlock Premium';

  @override
  String get oneTimePurchaseDesc => 'One-time purchase · yours forever · no subscription';

  @override
  String get viewPlansPrice => 'View Plans — \$6.99';

  @override
  String get premiumActive => 'Premium — Active';

  @override
  String get familyActive => 'Family — Active';

  @override
  String get cloudSyncEnabled => 'Cloud sync enabled';

  @override
  String get sharedWithMembers => 'Shared with up to 5 members';

  @override
  String get yourForever => 'yours forever';

  @override
  String get publishCookbookToStart => 'Publish a cookbook to start building your stats here';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get chooseFromLibrary => 'Choose from library';

  @override
  String get deleteAccountTitle => 'Permanently delete your account?';

  @override
  String get deleteAccountWarning => 'This will delete:\n· All your saved recipes\n· All your cookbooks\n· Your community publications\n· All account data\n\nThis cannot be undone.';

  @override
  String get typeDeleteToConfirmAccount => 'Type DELETE to confirm:';

  @override
  String get deleteForever => 'Delete Forever';

  @override
  String nameCooldownMessage(String date) {
    return 'You can change your name again on $date';
  }

  @override
  String get reportAccount => 'Report this account';

  @override
  String get reportAccountTitle => 'Why are you reporting this account?';

  @override
  String get reportSpam => 'Spam or fake account';

  @override
  String get reportInappropriate => 'Inappropriate content';

  @override
  String get reportStolen => 'Stolen recipes / copyright';

  @override
  String get reportHarassment => 'Harassment';

  @override
  String get reportOther => 'Other';

  @override
  String get submitReport => 'Submit Report';

  @override
  String get reportSubmitted => 'Thanks for your report. We\'ll review it shortly.';

  @override
  String get alreadyReportedRecently => 'You already reported this account recently';

  @override
  String get cannotReportSelf => 'You cannot report yourself';

  @override
  String get pendingAccountReports => 'Account Reports';

  @override
  String get accountReportsResolved => 'Account report resolved';

  @override
  String get accountReportDismissed => 'Account report dismissed';

  @override
  String get communityTrending => 'TRENDING';

  @override
  String get communitySearchTags => 'Search tags...';

  @override
  String communityNoTagsFound(String query) {
    return 'No tags found for \"$query\"';
  }

  @override
  String get communityConfirm => 'Confirm';

  @override
  String get cravingCardTitle => 'What are you craving?';

  @override
  String get cravingCardSubtitle => 'Find recipes that match your mood';

  @override
  String get cravingStep1Title => 'What are you feeling?';

  @override
  String get cravingStep2Title => 'Anything more specific?';

  @override
  String get cravingStep3Title => 'Where should we look?';

  @override
  String get cravingResultsTitle => 'Here\'s what we found';

  @override
  String get cravingPickOneOrMore => 'Pick one or more';

  @override
  String get cravingMoodHint => 'We\'ll find something you\'ll love';

  @override
  String cravingCountSelected(int count) {
    return '$count selected';
  }

  @override
  String get cravingCategoryHint => 'Optional — skip if you\'re open to anything';

  @override
  String get cravingCategoryNarrowHint => 'Narrow it down or skip ahead';

  @override
  String get cravingMoodSweet => 'Sweet';

  @override
  String get cravingMoodSavory => 'Savory';

  @override
  String get cravingMoodLight => 'Light';

  @override
  String get cravingMoodFilling => 'Filling';

  @override
  String get cravingMoodQuick => 'Quick';

  @override
  String get cravingMoodSpecial => 'Something Special';

  @override
  String get cravingCatDessert => 'Dessert';

  @override
  String get cravingCatPastry => 'Pastry';

  @override
  String get cravingCatBakedGoods => 'Baked Goods';

  @override
  String get cravingCatBreakfast => 'Breakfast';

  @override
  String get cravingCatDinner => 'Dinner';

  @override
  String get cravingCatLunch => 'Lunch';

  @override
  String get cravingCatAppetizer => 'Appetizer';

  @override
  String get cravingCatSoup => 'Soup';

  @override
  String get cravingCatSauce => 'Sauce';

  @override
  String get cravingCatSalad => 'Salad';

  @override
  String get cravingCatSnack => 'Snack';

  @override
  String get cravingCatMainDish => 'Main Dish';

  @override
  String get cravingCatPasta => 'Pasta';

  @override
  String get cravingCatRice => 'Rice Dishes';

  @override
  String get cravingCatCasserole => 'Casserole';

  @override
  String get cravingCatUnder20 => 'Under 20 min';

  @override
  String get cravingCatUnder30 => 'Under 30 min';

  @override
  String get cravingCat5Ings => '5 ingredients or less';

  @override
  String get cravingCatImpressive => 'Impressive';

  @override
  String get cravingCatCrowdPleaser => 'Crowd Pleaser';

  @override
  String get cravingCatFavorites => 'Favorites';

  @override
  String get cravingSourceMyRecipesTitle => 'My saved recipes';

  @override
  String get cravingSourceMyRecipesSubtitle => 'From your personal library';

  @override
  String get cravingSourceCommunityTitle => 'Discover something new';

  @override
  String get cravingSourceCommunitySubtitle => 'From the community';

  @override
  String get cravingSourceBothTitle => 'Both — surprise me';

  @override
  String get cravingSourceBothSubtitle => 'Mix of yours and community';

  @override
  String get cravingReshuffle => 'Reshuffle';

  @override
  String cravingFoundRecipes(int count) {
    return 'Found $count recipes matching your vibe';
  }

  @override
  String get cravingNothingFound => 'Nothing found for these filters';

  @override
  String get cravingTryBroader => 'Try broader options or reshuffle';

  @override
  String get cravingAdjustFilters => 'Adjust filters';

  @override
  String get cravingCookThis => 'Cook this recipe';

  @override
  String get cravingViewRecipe => 'View recipe';

  @override
  String get cravingNext => 'Next';

  @override
  String get cravingBack => 'Back';

  @override
  String get cravingSkipStep => 'Skip this step →';

  @override
  String get cravingFindRecipes => 'Find recipes';

  @override
  String get mergeCookbooksMenu => 'Merge cookbooks';

  @override
  String get mergeCookbooksTitle => 'Merge Cookbooks';

  @override
  String get mergeCookbooksNameLabel => 'New cookbook name';

  @override
  String get mergeCookbooksDefaultName => 'Merged Cookbook';

  @override
  String get mergeCookbooksNeedTwo => 'You need at least 2 cookbooks to merge';

  @override
  String get mergeCookbooksNoRecipes => 'No recipes to merge';

  @override
  String mergeCookbooksMerging(int count) {
    return 'Merging $count recipes...';
  }

  @override
  String mergeCookbooksCreated(String name, int count) {
    return 'Created \"$name\" with $count recipes';
  }

  @override
  String mergeCookbooksFailed(String error) {
    return 'Merge failed: $error';
  }

  @override
  String mergeCookbooksButton(int count) {
    return 'Merge $count cookbooks';
  }

  @override
  String get mergeCookbooksCancel => 'Cancel';

  @override
  String get combinedIngredients => 'Combined Ingredients';

  @override
  String get communitySubRecipe => 'Sub-recipe';

  @override
  String get copyToCookbook => 'Copy to cookbook';

  @override
  String get moveToCookbook => 'Move to cookbook';

  @override
  String get hintCookbookSwitcher => 'Tap the cookbook name at the top to switch between your cookbooks!';

  @override
  String get paywallPlanPremium => 'Premium';

  @override
  String get paywallPricePremium => '\$6.99';

  @override
  String get paywallSublinePremium => 'one-time · yours forever';

  @override
  String get paywallFeatureCloudSync => 'Cloud sync across devices';

  @override
  String get paywallFeatureStepPhotos => 'Step-by-step photos';

  @override
  String get paywallFeatureAutoBackups => 'Automatic backups';

  @override
  String get paywallPlanFamily => 'Family';

  @override
  String get paywallPriceFamily => '\$19.99';

  @override
  String get paywallSublineFamily => 'one-time · share with 5 people';

  @override
  String get paywallFeatureEverythingPremium => 'Everything in Premium';

  @override
  String get paywallFeatureFamilySync => 'Up to 5 family members sync together';

  @override
  String get paywallFeatureSharedCookbooks => 'Shared cookbooks & shopping lists';

  @override
  String get paywallPriceAnchor => 'Most recipe apps charge \$5–10/month. This isn\'t that.';

  @override
  String get paywallTrustLine => 'Pay once, yours forever.';

  @override
  String get paywallPrivacyPolicy => 'Privacy Policy';

  @override
  String get paywallTerms => 'Terms';

  @override
  String get paywallPurchaseSuccess => 'Purchase successful!';

  @override
  String get paywallCheckoutOpened => 'Complete your purchase in the browser window that just opened.';

  @override
  String get paywallWebComingSoonDesc => 'In-app purchases for web are coming soon. Please use the mobile app to subscribe.';

  @override
  String get paywallCompareFree => 'Free';

  @override
  String get paywallCompareUnlimitedRecipes => 'Unlimited recipes';

  @override
  String get paywallCompareCloudSync => 'Cloud sync';

  @override
  String get paywallCompareFamilySharing => 'Family sharing';

  @override
  String linkCurrentlyLinked(int count) {
    return '$count currently linked';
  }

  @override
  String get linkSearchRecipes => 'Search recipes...';

  @override
  String linkAvailable(int count) {
    return '$count available';
  }

  @override
  String linkNoMatch(String query) {
    return 'No match for \"$query\"';
  }

  @override
  String get linkNoRecipesAvailable => 'No recipes available';

  @override
  String linkFoundInOtherCookbooks(int count) {
    return '$count found in other cookbooks';
  }

  @override
  String get linkCopyToCookbookNote => 'Recipes from other cookbooks will be copied to this cookbook when linked.';

  @override
  String get linkWillBeCopied => 'Will be copied to this cookbook';

  @override
  String get bulkCopyLabel => 'Copy';

  @override
  String get bulkDeleteLabel => 'Delete';

  @override
  String get bulkMoveLabel => 'Move';

  @override
  String get bulkPinned => 'Pinned';

  @override
  String get recipeListCreateCookbookFirst => 'Create another cookbook first';

  @override
  String recipeListRecipesCopied(int count) {
    return '$count recipes copied';
  }

  @override
  String recipeListRecipesMoved(int count) {
    return '$count recipes moved';
  }

  @override
  String selectAllBar(int selectedCount, int totalCount) {
    return '$selectedCount of $totalCount selected';
  }

  @override
  String get sortAToZ => 'A to Z';

  @override
  String get sortZToA => 'Z to A';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortOldest => 'Oldest';

  @override
  String get sortRating => 'Rating';

  @override
  String get sortQuickest => 'Quickest';

  @override
  String get sortFavorites => 'Favorites';

  @override
  String get viewSizeSmall => 'Small';

  @override
  String get viewSizeMedium => 'Medium';

  @override
  String get viewSizeLarge => 'Large';

  @override
  String trashSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String trashBulkRestored(int count) {
    return '$count recipes restored';
  }

  @override
  String trashBulkDeleteConfirm(int count) {
    return 'Permanently delete $count recipes? This cannot be undone.';
  }

  @override
  String trashDeletingCount(int count) {
    return 'Deleting $count recipes...';
  }

  @override
  String trashBulkDeleted(int count) {
    return '$count recipes deleted';
  }

  @override
  String get shareViewerExpired => 'This share link has expired';

  @override
  String get shareViewerExpiredLabel => 'Expired';

  @override
  String get shareViewerFailed => 'Failed to load shared recipes';

  @override
  String get shareViewerNoConnection => 'No internet connection';

  @override
  String shareViewerHoursRemaining(int hours) {
    return '${hours}h remaining';
  }

  @override
  String shareViewerMinutesRemaining(int minutes) {
    return '${minutes}m remaining';
  }

  @override
  String shareViewerRecipeCount(int count) {
    return '$count recipes';
  }

  @override
  String get shareViewerUntitled => 'Untitled Recipe';

  @override
  String get subRecipeSheetCopyTitle => 'Copy with sub-recipes?';

  @override
  String get subRecipeSheetMoveTitle => 'Move with sub-recipes?';

  @override
  String get subRecipeSheetDeleteTitle => 'Delete recipe and sub-recipes?';

  @override
  String get subRecipeSheetPublishTitle => 'Publish with sub-recipes?';

  @override
  String get subRecipeSheetDownloadTitle => 'Download with sub-recipes?';

  @override
  String subRecipeSheetSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This recipe links $count sub-recipes',
      one: 'This recipe links 1 sub-recipe',
    );
    return '$_temp0 — uncheck any you don\'t want to include.';
  }

  @override
  String subRecipeUsedInOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count other recipes',
      one: '1 other recipe',
    );
    return 'Used in $_temp0';
  }

  @override
  String get subRecipeUsedNowhere => 'Not used in any other recipes';

  @override
  String autoLinkedSubRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'auto-linked $count sub-recipes',
      one: 'auto-linked 1 sub-recipe',
    );
    return '$_temp0';
  }

  @override
  String get importNearDuplicateExisting => 'Similar exists';

  @override
  String get importNearDuplicateInternal => 'Similar in batch';

  @override
  String get backupReminderTitle => 'Cloud sync isn\'t on';

  @override
  String backupReminderDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Last backup was $count days ago',
      one: 'Last backup was 1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get backupReminderNever => 'Sign in to keep your recipes synced — or back up manually.';

  @override
  String get backupReminderAction => 'Sign in';

  @override
  String get backupReminderSnooze => 'Remind me later';

  @override
  String get communityDownloadIncludeSubRecipesTitle => 'Include linked sub-recipes?';

  @override
  String communityDownloadIncludeSubRecipesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The recipes you selected reference $count sub-recipes. Include them so the links don\'t break?',
      one: 'The recipes you selected reference 1 sub-recipe. Include it so the link doesn\'t break?',
    );
    return '$_temp0';
  }

  @override
  String get communityDownloadIncludeSubRecipes => 'Include sub-recipes';

  @override
  String get communityDownloadSkipSubRecipes => 'Skip them';

  @override
  String get actionMove => 'Move';

  @override
  String get communityDownload => 'Download';

  @override
  String get exportFullZip => 'Full Backup (ZIP)';

  @override
  String get exportFullZipSubtitle => 'All data + images in a portable archive';

  @override
  String get importFromFileSubtitle => 'Supports .json and .zip backup files';

  @override
  String get exportAdvanced => 'Advanced options';

  @override
  String get exportCurrentCookbookSubtitle => 'JSON file of current cookbook only';

  @override
  String get exportJsonCustom => 'Custom JSON export';

  @override
  String get editAsText => 'Edit as text';

  @override
  String get editAsList => 'Edit as list';

  @override
  String get stepsBulkEditHint => 'Separate each step with a blank line';

  @override
  String get stepsBulkEditImagesWarning => 'Some step photos may be lost if you change the number of steps.';

  @override
  String get publishToCommunity => 'Publish to community';

  @override
  String get publishSingleRecipeTitle => 'Publish recipe';

  @override
  String get publishSingleRecipeBody => 'Share this recipe to the community feed. Updates won\'t sync — re-publish to push changes.';

  @override
  String get publishSingleRecipeAction => 'Publish';

  @override
  String get publishSingleRecipeSuccess => 'Published!';

  @override
  String get creatorsYouFollow => 'Creators you follow';

  @override
  String get noCreatorsYouFollow => 'Follow creators to see their latest publications here.';

  @override
  String get shoppingAlsoAddToMealPlan => 'Also add to meal plan';

  @override
  String shoppingMealPlanAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Added $count recipes to meal plan',
      one: 'Added 1 recipe to meal plan',
    );
    return '$_temp0';
  }

  @override
  String get communityICookedThis => 'I cooked this';

  @override
  String get communityICookedThisActive => 'Cooked';

  @override
  String get communityRepublishRecipes => 'Update published version';

  @override
  String get communityRepublishRecipesBody => 'Replaces the published recipe content with your current version. Ratings and downloads are kept.';

  @override
  String get communityRepublishRecipesAction => 'Update';

  @override
  String get communityRepublishSuccess => 'Published version updated';

  @override
  String get shoppingItemRemoved => 'Item removed';

  @override
  String shoppingItemsRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items removed',
      one: '1 item removed',
    );
    return '$_temp0';
  }

  @override
  String get publicationUnpublished => 'Unpublished';

  @override
  String get cookModeVoiceTitle => 'Voice control';

  @override
  String get cookModeVoiceListening => 'Listening… say next, back, pause, or set timer';

  @override
  String get cookModeVoiceUnavailable => 'Voice control unavailable on this device';

  @override
  String get communityRepublishSourceMissing => 'Couldn\'t find the original recipe on this device. Publish it again from the recipe to share an updated version.';

  @override
  String get importNothingSaved => 'Import failed — nothing was saved. Please try again.';

  @override
  String get unsavedChangesBody => 'You have unsaved changes. Leave without saving?';

  @override
  String get unsavedKeepEditing => 'Keep editing';

  @override
  String get unsavedDiscard => 'Discard';

  @override
  String get ingredientMakeHeader => 'Make section header';

  @override
  String get ingredientMakeIngredient => 'Make ingredient';

  @override
  String get shoppingMoveToList => 'Move to list';

  @override
  String get shoppingNoOtherLists => 'No other lists to move to';

  @override
  String shoppingMovedToList(String name) {
    return 'Moved to $name';
  }

  @override
  String get exportSaveToDevice => 'Save to device';

  @override
  String get exportSaveToDeviceSubtitle => 'Save the backup zip to your files or Downloads';

  @override
  String get exportShareZip => 'Share backup';

  @override
  String get exportShareZipSubtitle => 'Send the backup to another app or device';

  @override
  String get exportSaved => 'Backup saved';

  @override
  String get exportZipIncludeShopping => 'Include shopping lists';

  @override
  String get exportZipIncludeShoppingSubtitle => 'Add your shopping lists to the full backup';

  @override
  String get communityPublishCookbookOption => 'Publish a cookbook';

  @override
  String get communityPublishCookbookOptionSub => 'Share a whole cookbook (5+ recipes)';

  @override
  String get communityPublishSingleRecipeOption => 'Publish a single recipe';

  @override
  String get communityPublishSingleRecipeOptionSub => 'Share one recipe — no cookbook needed';

  @override
  String get communityPickRecipeToPublish => 'Choose a recipe to publish';

  @override
  String get communitySearchYourRecipes => 'Search your recipes…';

  @override
  String get chartCompactDonut => 'Compact';

  @override
  String get nutritionPaletteTitle => 'Color palette';

  @override
  String get paletteClassic => 'Classic';

  @override
  String get paletteWarm => 'Warm';

  @override
  String get paletteCool => 'Cool';

  @override
  String get paletteMono => 'Mono';
}
