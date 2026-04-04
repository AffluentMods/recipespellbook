// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Recipe Spellbook';

  @override
  String get navHome => 'Startpagina';

  @override
  String get navCookbooks => 'Kookboeken';

  @override
  String get navPlanner => 'Planner';

  @override
  String get navShopping => 'Boodschappen';

  @override
  String get navSettings => 'Instellingen';

  @override
  String get homeGreeting => 'Welkom terug!';

  @override
  String get homeQuickAccess => 'Snelle toegang';

  @override
  String get homeMealPlan => 'Maaltijden van vandaag';

  @override
  String get homePinnedRecipes => 'Vastgezette recepten';

  @override
  String get homeRecentRecipes => 'Recent bekeken';

  @override
  String get homeNoMealsPlanned => 'Geen maaltijden gepland voor vandaag';

  @override
  String get homeNoPinnedRecipes => 'Nog geen vastgezette recepten';

  @override
  String get homeNoRecentRecipes => 'Geen recente recepten';

  @override
  String get recipesTitle => 'Recepten';

  @override
  String get recipesEmpty => 'Nog geen recepten';

  @override
  String get recipesEmptySubtitle => 'Voeg je eerste recept toe om te beginnen';

  @override
  String get recipeAdd => 'Recept toevoegen';

  @override
  String get recipeEdit => 'Recept bewerken';

  @override
  String get recipeDelete => 'Recept verwijderen';

  @override
  String get recipeDeleteConfirm => 'Weet je zeker dat je dit recept wilt verwijderen?';

  @override
  String get recipeFavorite => 'Toevoegen aan favorieten';

  @override
  String get recipeUnfavorite => 'Verwijderen uit favorieten';

  @override
  String get recipePin => 'Recept vastzetten';

  @override
  String get recipeUnpin => 'Recept losmaken';

  @override
  String get recipeShare => 'Recept delen';

  @override
  String get recipePrint => 'Recept afdrukken';

  @override
  String get recipeDuplicate => 'Recept dupliceren';

  @override
  String get recipeAddToMealPlan => 'Toevoegen aan maaltijdplan';

  @override
  String get recipeAddToShoppingList => 'Toevoegen aan boodschappenlijst';

  @override
  String get recipeStartCooking => 'Beginnen met koken';

  @override
  String get recipeFieldTitle => 'Titel';

  @override
  String get recipeFieldDescription => 'Beschrijving';

  @override
  String get recipeFieldIngredients => 'Ingrediënten';

  @override
  String get recipeFieldInstructions => 'Instructies';

  @override
  String get recipeFieldNotes => 'Notities';

  @override
  String get notesTitle => 'Notities';

  @override
  String get recipeFieldServings => 'Porties';

  @override
  String get recipeFieldPrepTime => 'Voorbereidingstijd';

  @override
  String get recipeFieldCookTime => 'Kooktijd';

  @override
  String get recipeFieldTotalTime => 'Totale tijd';

  @override
  String get recipeFieldSource => 'Bron';

  @override
  String get recipeFieldCourse => 'Gang';

  @override
  String get recipeFieldCategory => 'Categorie';

  @override
  String get recipeFieldTags => 'Labels';

  @override
  String get recipeFieldRating => 'Beoordeling';

  @override
  String get ratingCommon => 'Gewoon';

  @override
  String get ratingUncommon => 'Ongewoon';

  @override
  String get ratingRare => 'Zeldzaam';

  @override
  String get ratingEpic => 'Episch';

  @override
  String get ratingLegendary => 'Legendarisch';

  @override
  String get ratingUnrated => 'Niet beoordeeld';

  @override
  String get minutesAbbrev => 'min';

  @override
  String get hoursAbbrev => 'u';

  @override
  String get servingsUnit => 'porties';

  @override
  String get ingredientsTitle => 'Ingrediënten';

  @override
  String get ingredientsEmpty => 'Geen ingrediënten toegevoegd';

  @override
  String get ingredientAdd => 'Ingrediënt toevoegen';

  @override
  String get ingredientPlaceholder => 'bijv. 2 kopjes bloem';

  @override
  String get instructionsTitle => 'Instructies';

  @override
  String get instructionsEmpty => 'Geen instructies toegevoegd';

  @override
  String get instructionAdd => 'Stap toevoegen';

  @override
  String get instructionPlaceholder => 'Beschrijf deze stap...';

  @override
  String stepNumber(int number) {
    return 'Stap $number';
  }

  @override
  String get cookbooksTitle => 'Kookboeken';

  @override
  String get cookbooksEmpty => 'Nog geen kookboeken';

  @override
  String get cookbookAdd => 'Nieuw kookboek';

  @override
  String get cookbookEdit => 'Kookboek bewerken';

  @override
  String get cookbookDelete => 'Kookboek verwijderen';

  @override
  String get cookbookDeleteConfirm => 'Dit kookboek en alle recepten verwijderen?';

  @override
  String cookbookRecipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recepten',
      one: '1 recept',
      zero: 'Geen recepten',
    );
    return '$_temp0';
  }

  @override
  String get shoppingDeli => 'Delicatessen';

  @override
  String get shoppingCannedGoods => 'Blikvoer & Soepen';

  @override
  String get shoppingCondiments => 'Condimenten & Sauzen';

  @override
  String get shoppingGrainsAndPasta => 'Granen, Pasta & Rijst';

  @override
  String get shoppingCookingAndBaking => 'Koken & Bakken';

  @override
  String get shoppingBreakfastCereal => 'Ontbijt & Granen';

  @override
  String get shoppingBeerWineSpirits => 'Bier, Wijn & Sterke drank';

  @override
  String get shoppingBaby => 'Baby';

  @override
  String get shoppingPet => 'Huisdier';

  @override
  String get shoppingHousehold => 'Huishouden';

  @override
  String get shoppingPersonalCare => 'Persoonlijke verzorging';

  @override
  String get plannerTitle => 'Maaltijdplanner';

  @override
  String get plannerEmpty => 'Geen maaltijden gepland';

  @override
  String get plannerEmptySubtitle => 'Tik op + om een maaltijd toe te voegen';

  @override
  String get plannerAddMeal => 'Maaltijd toevoegen';

  @override
  String get plannerToday => 'Vandaag';

  @override
  String get plannerThisWeek => 'Deze week';

  @override
  String get plannerBreakfast => 'Ontbijt';

  @override
  String get plannerLunch => 'Lunch';

  @override
  String get plannerDinner => 'Diner';

  @override
  String get plannerSnack => 'Snack';

  @override
  String get shoppingTitle => 'Boodschappenlijst';

  @override
  String get shoppingEmpty => 'Je lijst is leeg';

  @override
  String get shoppingEmptySubtitle => 'Voeg items toe of importeer vanuit recepten';

  @override
  String get shoppingAddItem => 'Item toevoegen...';

  @override
  String get shoppingCheckedItems => 'Aangevinkte items';

  @override
  String get shoppingClearChecked => 'Aangevinkte items verwijderen';

  @override
  String get shoppingClearAll => 'Alles verwijderen';

  @override
  String get shoppingCategories => 'Boodschappencategorieën';

  @override
  String get shoppingUncategorized => 'Ongecategoriseerd';

  @override
  String shoppingItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'Geen items',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get settingsAppearance => 'Uiterlijk';

  @override
  String get settingsTheme => 'Thema';

  @override
  String get settingsThemeMode => 'Theemmodus';

  @override
  String get settingsThemeModeSystem => 'Systeem';

  @override
  String get settingsThemeModeLight => 'Licht';

  @override
  String get settingsThemeModeDark => 'Donker';

  @override
  String get settingsLanguage => 'Taal';

  @override
  String get settingsMeasurements => 'Maten';

  @override
  String get settingsMeasurementsUS => 'VS (kopjes, oz)';

  @override
  String get settingsMeasurementsMetric => 'Metrisch (ml, g)';

  @override
  String get settingsKitchenBuddy => 'RPG-modus';

  @override
  String get settingsKitchenBuddySubtitle => 'Fantasy-stijl tekst en afbeeldingen inschakelen';

  @override
  String get settingsRecipes => 'Recepten';

  @override
  String get settingsManageCourses => 'Gangen beheren';

  @override
  String get settingsManageCategories => 'Categorieën beheren';

  @override
  String get settingsManageTags => 'Labels beheren';

  @override
  String get settingsData => 'Gegevens';

  @override
  String get settingsExport => 'Gegevens exporteren';

  @override
  String get settingsExportSubtitle => 'Back-up van je recepten';

  @override
  String get settingsImport => 'Gegevens importeren';

  @override
  String get settingsImportSubtitle => 'Herstellen van back-up';

  @override
  String get settingsImportFromApps => 'Importeren vanuit andere apps';

  @override
  String get settingsImportFromAppsSubtitle => 'Paprika, Crouton, Mela en meer';

  @override
  String get settingsAbout => 'Over';

  @override
  String settingsVersion(String version) {
    return 'Versie $version';
  }

  @override
  String get settingsPrivacy => 'Privacybeleid';

  @override
  String get settingsTerms => 'Servicevoorwaarden';

  @override
  String get settingsFeedback => 'Feedback sturen';

  @override
  String get importTitle => 'Importeren';

  @override
  String get importCreate => 'Aanmaken';

  @override
  String get importCreateSubtitle => 'Schrijf je eigen recept';

  @override
  String get importSubtitle => 'Van URL, afbeelding of bestand';

  @override
  String get importChooseMethod => 'Hoe wil je je recept toevoegen?';

  @override
  String get importProgress => 'Recept importeren...';

  @override
  String get importFromURL => 'Van URL';

  @override
  String get importFromImage => 'Van afbeelding';

  @override
  String get importFromFile => 'Van bestand';

  @override
  String get importFromText => 'Importeren van tekst';

  @override
  String get importProcessing => 'Verwerken...';

  @override
  String get importSuccess => 'Recept succesvol geïmporteerd';

  @override
  String get importError => 'Importeren mislukt';

  @override
  String get importBulkTitle => 'Recepten importeren';

  @override
  String importBulkFound(int count) {
    return '$count recepten gevonden';
  }

  @override
  String get importBulkImportAll => 'Alles importeren';

  @override
  String get importBulkImportFirst => 'Eerste importeren';

  @override
  String get searchTitle => 'Zoeken';

  @override
  String get searchHint => 'Recepten zoeken...';

  @override
  String get searchNoResults => 'Geen recepten gevonden';

  @override
  String get searchFilters => 'Filters';

  @override
  String get actionSave => 'Opslaan';

  @override
  String get actionCancel => 'Annuleren';

  @override
  String get actionDelete => 'Verwijderen';

  @override
  String get actionEdit => 'Bewerken';

  @override
  String get actionAdd => 'Toevoegen';

  @override
  String get actionDone => 'Klaar';

  @override
  String get actionClose => 'Sluiten';

  @override
  String get actionConfirm => 'Bevestigen';

  @override
  String get actionUndo => 'Ongedaan maken';

  @override
  String get actionRetry => 'Opnieuw proberen';

  @override
  String get actionCopy => 'Kopiëren';

  @override
  String get actionPaste => 'Plakken';

  @override
  String get actionOk => 'OK';

  @override
  String get actionShare => 'Delen';

  @override
  String get actionClear => 'Wissen';

  @override
  String get errorGeneric => 'Er is iets misgegaan';

  @override
  String get errorNetwork => 'Netwerkfout. Controleer je verbinding.';

  @override
  String get errorNotFound => 'Niet gevonden';

  @override
  String get errorInvalidURL => 'Ongeldige URL';

  @override
  String get successSaved => 'Succesvol opgeslagen';

  @override
  String get successDeleted => 'Succesvol verwijderd';

  @override
  String get successCopied => 'Gekopieerd naar klembord';

  @override
  String get confirmDeleteTitle => 'Verwijdering bevestigen';

  @override
  String get confirmDeleteMessage => 'Deze actie kan niet ongedaan worden gemaakt.';

  @override
  String get emptyStateTitle => 'Hier is nog niets';

  @override
  String get emptyStateSubtitle => 'Begin door je eerste item toe te voegen';

  @override
  String get dateToday => 'Vandaag';

  @override
  String get dateYesterday => 'Gisteren';

  @override
  String get dateTomorrow => 'Morgen';

  @override
  String timeMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'minuten',
      one: 'minuut',
    );
    return '$count $_temp0';
  }

  @override
  String timeHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'uur',
      one: 'uur',
    );
    return '$count $_temp0';
  }

  @override
  String get trashTitle => 'Prullenbak';

  @override
  String get trashEmpty => 'Prullenbak is leeg';

  @override
  String get trashEmptySubtitle => 'Verwijderde recepten verschijnen hier 30 dagen lang';

  @override
  String get trashRestore => 'Herstellen';

  @override
  String get trashRestored => 'hersteld';

  @override
  String get trashDeletePermanently => 'Definitief verwijderen';

  @override
  String get trashEmptyTrash => 'Prullenbak legen';

  @override
  String get trashEmptyConfirm => 'Dit verwijdert alle recepten in de prullenbak definitief. Deze actie kan niet ongedaan worden gemaakt.';

  @override
  String get trashEmptied => 'Prullenbak geleegd';

  @override
  String get trashDeleted => 'Verwijderd';

  @override
  String get trashDeletedToday => 'Vandaag verwijderd';

  @override
  String get trashDeletedYesterday => 'Gisteren verwijderd';

  @override
  String trashDeletedDaysAgo(int days) {
    return '$days dagen geleden verwijderd';
  }

  @override
  String get trashExpiresToday => 'Verloopt vandaag';

  @override
  String trashDaysLeft(int days) {
    return 'Nog $days dagen';
  }

  @override
  String get cookingModeTitle => 'Kookmodus';

  @override
  String get cookingSetTimer => 'Timer instellen';

  @override
  String get cookingTimerDone => 'Timer klaar!';

  @override
  String get cookingTimerFinished => 'Je timer is afgelopen.';

  @override
  String get cookingExitTitle => 'Kookmodus verlaten?';

  @override
  String get cookingExitMessage => 'Je voortgang gaat verloren.';

  @override
  String get cookingExit => 'Verlaten';

  @override
  String get cookingFinish => 'Voltooien';

  @override
  String get taxonomyAddCourse => 'Gang toevoegen';

  @override
  String get taxonomyEditCourse => 'Gang bewerken';

  @override
  String get taxonomyDeleteCourse => 'Gang verwijderen?';

  @override
  String get taxonomyAddCategory => 'Categorie toevoegen';

  @override
  String get taxonomyEditCategory => 'Categorie bewerken';

  @override
  String get taxonomyDeleteCategory => 'Categorie verwijderen?';

  @override
  String get taxonomyBuiltIn => 'Standaard';

  @override
  String get taxonomyCustom => 'Aangepast';

  @override
  String get taxonomyRestoreDefaults => 'Standaarden herstellen';

  @override
  String get taxonomyDefaultsRestored => 'Aangepaste items verwijderd, standaarden hersteld';

  @override
  String get taxonomyCourseName => 'Naam gang';

  @override
  String get taxonomyCourseNameHint => 'bijv. Brunch, Voorgerecht';

  @override
  String get taxonomyCategoryName => 'Naam categorie';

  @override
  String get taxonomyCategoryNameHint => 'bijv. Glutenvrij, Weinig koolhydraten';

  @override
  String get taxonomyEmojiHint => 'Tik op het emojiveld om te bewerken';

  @override
  String taxonomyDeleteCourseMessage(String name) {
    return 'Gang \"$name\" verwijderen? Recepten met deze gang worden ongecategoriseerd.';
  }

  @override
  String taxonomyDeleteCategoryMessage(String name) {
    return 'Categorie \"$name\" verwijderen? Recepten met deze categorie worden ongecategoriseerd.';
  }

  @override
  String get settingsQuickAccess => 'Snelle toegang';

  @override
  String get settingsPlaceholders => 'Standaardafbeeldingen';

  @override
  String get actionView => 'Weergeven';

  @override
  String get browseViewAll => 'Alle recepten bekijken';

  @override
  String browseRecipesTotal(int count) {
    return '$count recepten in totaal';
  }

  @override
  String get browseCourses => 'Gangen';

  @override
  String get browseCategories => 'Categorieën';

  @override
  String get browseNoCourse => 'Zonder gang';

  @override
  String get browseUncategorized => 'Ongecategoriseerd';

  @override
  String get favoritesTitle => 'Favorieten';

  @override
  String get favoritesEmpty => 'Geen favoriete recepten';

  @override
  String get favoritesEmptySubtitle => 'Tik op de ster van een recept om het hier toe te voegen';

  @override
  String get favoritesRemoved => 'Verwijderd uit favorieten';

  @override
  String get recentTitle => 'Recent bekeken';

  @override
  String get recentEmpty => 'Geen recente recepten';

  @override
  String get recentEmptySubtitle => 'Recepten die je bekijkt verschijnen hier';

  @override
  String get recentJustNow => 'Zojuist';

  @override
  String recentMinutesAgo(int count) {
    return '$count min geleden';
  }

  @override
  String recentHoursAgo(int count) {
    return '$count uur geleden';
  }

  @override
  String get recentYesterday => 'Gisteren';

  @override
  String recentDaysAgo(int count) {
    return '$count dagen geleden';
  }

  @override
  String get importFromUrl => 'Importeren van URL';

  @override
  String get importUrlHint => 'Recept-URL';

  @override
  String get importUrlPlaceholder => 'https://voorbeeld.nl/recept';

  @override
  String get importFetch => 'Recept ophalen';

  @override
  String get importFetching => 'Ophalen...';

  @override
  String get importPreview => 'Voorbeeld';

  @override
  String get importRecipeFound => 'Recept gevonden!';

  @override
  String get importReviewSave => 'Bekijken en opslaan';

  @override
  String get importEditBeforeSave => 'Je kunt het recept bewerken voor het opslaan';

  @override
  String get importSupportedSites => 'Ondersteunde sites';

  @override
  String get importSupportedSitesInfo => 'Werkt met de meeste receptsites!';

  @override
  String get importFromScan => 'Recept scannen';

  @override
  String get importFromPdf => 'Importeren van PDF';

  @override
  String get cookbookNew => 'Nieuw kookboek';

  @override
  String get cookbookNameLabel => 'Naam kookboek';

  @override
  String get cookbookNameHint => 'bijv. Familierecepten';

  @override
  String get cookbookDescLabel => 'Beschrijving';

  @override
  String get cookbookDescHint => 'Een verzameling recepten...';

  @override
  String get cookbookAddCover => 'Omslag toevoegen';

  @override
  String get cookbookTapToAdd => 'Tik om omslagafbeelding toe te voegen';

  @override
  String get cookbookDeleteTitle => 'Kookboek verwijderen?';

  @override
  String cookbookDeleteMessage(int count) {
    return 'Dit kookboek bevat $count recepten. Ze worden naar de prullenbak verplaatst.';
  }

  @override
  String get cookbookCannotDelete => 'Je kunt je enige kookboek niet verwijderen';

  @override
  String get fontSizeTitle => 'Tekstgrootte';

  @override
  String get fontSizeReset => 'Standaard herstellen';

  @override
  String get fontSizeSmaller => 'Kleinere tekst';

  @override
  String get fontSizeLarger => 'Grotere tekst';

  @override
  String get defaultCookbookName => 'Mijn recepten';

  @override
  String get defaultCookbookDescription => 'Je persoonlijke receptenverzameling';

  @override
  String get defaultShoppingListName => 'Boodschappenlijst';

  @override
  String get courseBreakfast => 'Ontbijt';

  @override
  String get courseLunch => 'Lunch';

  @override
  String get courseDinner => 'Diner';

  @override
  String get courseAppetizer => 'Voorgerecht';

  @override
  String get courseSoup => 'Soep';

  @override
  String get courseSalad => 'Salade';

  @override
  String get courseMain => 'Hoofdgerecht';

  @override
  String get courseSide => 'Bijgerecht';

  @override
  String get courseDessert => 'Dessert';

  @override
  String get courseSnack => 'Snack';

  @override
  String get courseBeverage => 'Drank';

  @override
  String get categoryQuick => 'Snel & Makkelijk';

  @override
  String get categoryHealthy => 'Gezond';

  @override
  String get categoryComfort => 'Troosteten';

  @override
  String get categoryVegetarian => 'Vegetarisch';

  @override
  String get categoryVegan => 'Veganistisch';

  @override
  String get categoryGlutenFree => 'Glutenvrij';

  @override
  String get categoryDairyFree => 'Zuivelvrij';

  @override
  String get categoryLowCarb => 'Weinig koolhydraten';

  @override
  String get categorySpicy => 'Pittig';

  @override
  String get categoryFamilyFriendly => 'Gezinsvriendelijk';

  @override
  String get categoryParty => 'Feest';

  @override
  String get categoryHoliday => 'Feestdagen';

  @override
  String get categoryBbq => 'BBQ & Grill';

  @override
  String get categoryBaking => 'Bakken';

  @override
  String get shoppingProduce => 'Groente & Fruit';

  @override
  String get shoppingDairy => 'Zuivel & Eieren';

  @override
  String get shoppingMeat => 'Vlees & Gevogelte';

  @override
  String get shoppingSeafood => 'Zeevruchten';

  @override
  String get shoppingBakery => 'Bakkerij';

  @override
  String get shoppingFrozen => 'Diepvries';

  @override
  String get shoppingPantry => 'Voorraadkast';

  @override
  String get shoppingSpices => 'Kruiden & Specerijen';

  @override
  String get shoppingBeverages => 'Dranken';

  @override
  String get shoppingSnacks => 'Snacks';

  @override
  String get shoppingInternational => 'Internationaal';

  @override
  String get shoppingOther => 'Overig';

  @override
  String get unitCup => 'kopje';

  @override
  String get unitCups => 'kopjes';

  @override
  String get unitTablespoon => 'eetlepel';

  @override
  String get unitTablespoonAbbrev => 'el';

  @override
  String get unitTeaspoon => 'theelepel';

  @override
  String get unitTeaspoonAbbrev => 'tl';

  @override
  String get unitFluidOunce => 'vloeistofons';

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
  String get unitOunce => 'ons';

  @override
  String get unitOunceAbbrev => 'oz';

  @override
  String get unitPound => 'pond';

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
  String get unitPinch => 'snufje';

  @override
  String get unitDash => 'scheutje';

  @override
  String get unitClove => 'teen';

  @override
  String get unitCloves => 'tenen';

  @override
  String get unitHead => 'bol';

  @override
  String get unitBunch => 'bosje';

  @override
  String get unitCan => 'blik';

  @override
  String get unitPackage => 'pakket';

  @override
  String get unitSlice => 'plakje';

  @override
  String get unitSlices => 'plakjes';

  @override
  String get unitPiece => 'stuk';

  @override
  String get unitPieces => 'stuks';

  @override
  String get unitWhole => 'geheel';

  @override
  String get unitLarge => 'groot';

  @override
  String get unitMedium => 'middel';

  @override
  String get unitSmall => 'klein';

  @override
  String get unitFahrenheit => '°F';

  @override
  String get unitCelsius => '°C';

  @override
  String get unitInch => 'inch';

  @override
  String get unitInches => 'inch';

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
  String get convertUnitsTitle => 'Eenheden omrekenen';

  @override
  String get convertMetricToImperial => 'Metrisch → Imperiaal';

  @override
  String get convertMetricToImperialDesc => 'ml → fl oz, g → oz, kg → lb';

  @override
  String get convertImperialToMetric => 'Imperiaal → Metrisch';

  @override
  String get convertImperialToMetricDesc => 'kopjes → ml, oz → g, tl → ml';

  @override
  String get convertResetToOriginal => 'Herstellen naar origineel';

  @override
  String get settingsRecipeLayout => 'Receptindeling';

  @override
  String get settingsRecipeLayoutDescription => 'Kies hoe ingrediënten en instructies worden weergegeven';

  @override
  String get settingsRecipeDisplay => 'Receptweergave';

  @override
  String get layoutStacked => 'Gestapeld';

  @override
  String get layoutStackedDescription => 'Alle inhoud in een scrollbare lijst';

  @override
  String get layoutTabbed => 'Tabbladen';

  @override
  String get layoutTabbedDescription => 'Veeg tussen ingrediënten en instructies';

  @override
  String get recipeSwipeHint => 'Veeg om van sectie te wisselen';

  @override
  String get recipeIngredients => 'Ingrediënten';

  @override
  String get recipeInstructions => 'Instructies';

  @override
  String get dateNextWeek => 'Volgende week';

  @override
  String get timeJustNow => 'Zojuist';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuten geleden',
      one: '1 minuut geleden',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uur geleden',
      one: '1 uur geleden',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dagen geleden',
      one: '1 dag geleden',
    );
    return '$_temp0';
  }

  @override
  String timeWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weken geleden',
      one: '1 week geleden',
    );
    return '$_temp0';
  }

  @override
  String timeMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count maanden geleden',
      one: '1 maand geleden',
    );
    return '$_temp0';
  }

  @override
  String timeYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jaar geleden',
      one: '1 jaar geleden',
    );
    return '$_temp0';
  }

  @override
  String timeInMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuten',
      one: '1 minuut',
    );
    return 'over $_temp0';
  }

  @override
  String timeInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uur',
      one: '1 uur',
    );
    return 'over $_temp0';
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
      other: '$count u',
      one: '1 u',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours u $minutes min';
  }

  @override
  String countRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recepten',
      one: '1 recept',
      zero: 'Geen recepten',
    );
    return '$_temp0';
  }

  @override
  String countIngredients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingrediënten',
      one: '1 ingrediënt',
      zero: 'Geen ingrediënten',
    );
    return '$_temp0';
  }

  @override
  String countSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stappen',
      one: '1 stap',
      zero: 'Geen stappen',
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
      zero: 'Geen items',
    );
    return '$_temp0';
  }

  @override
  String countSelected(int count) {
    return '$count geselecteerd';
  }

  @override
  String get errorGenericTitle => 'Fout';

  @override
  String get errorGenericMessage => 'Er is iets misgegaan. Probeer opnieuw.';

  @override
  String get errorNetworkTitle => 'Verbindingsfout';

  @override
  String get errorNetworkMessage => 'Controleer je verbinding en probeer opnieuw.';

  @override
  String get errorNotFoundTitle => 'Niet gevonden';

  @override
  String get errorNotFoundMessage => 'De gevraagde inhoud is niet gevonden.';

  @override
  String get errorInvalidUrlTitle => 'Ongeldige URL';

  @override
  String get errorInvalidUrlMessage => 'Voer een geldige URL in die begint met http:// of https://';

  @override
  String get errorPermissionDenied => 'Toestemming geweigerd';

  @override
  String get errorStorageFull => 'Opslag vol';

  @override
  String get errorFileNotFound => 'Bestand niet gevonden';

  @override
  String get errorUnsupportedFormat => 'Bestandsformaat niet ondersteund';

  @override
  String get errorParsingFailed => 'Verwerken van inhoud mislukt';

  @override
  String get errorSaveFailed => 'Opslaan mislukt';

  @override
  String get errorLoadFailed => 'Laden mislukt';

  @override
  String get errorDeleteFailed => 'Verwijderen mislukt';

  @override
  String get errorImportFailed => 'Importeren mislukt';

  @override
  String get errorExportFailed => 'Exporteren mislukt';

  @override
  String get errorCameraAccess => 'Kan geen toegang krijgen tot camera';

  @override
  String get errorGalleryAccess => 'Kan geen toegang krijgen tot galerij';

  @override
  String get errorTimeout => 'Tijdslimiet overschreden';

  @override
  String get errorServerError => 'Serverfout. Probeer later opnieuw.';

  @override
  String get errorNoRecipeFound => 'Geen recept gevonden op deze pagina';

  @override
  String get errorInvalidRecipe => 'Ongeldige receptgegevens';

  @override
  String get errorDuplicateRecipe => 'Dit recept bestaat al';

  @override
  String get validationRequired => 'Dit veld is verplicht';

  @override
  String validationTooShort(int min) {
    return 'Moet minimaal $min tekens bevatten';
  }

  @override
  String validationTooLong(int max) {
    return 'Moet minder dan $max tekens bevatten';
  }

  @override
  String get validationInvalidEmail => 'Voer een geldig e-mailadres in';

  @override
  String get validationInvalidUrl => 'Voer een geldige URL in';

  @override
  String get validationInvalidNumber => 'Voer een geldig getal in';

  @override
  String validationMinValue(int min) {
    return 'Moet minimaal $min zijn';
  }

  @override
  String validationMaxValue(int max) {
    return 'Moet maximaal $max zijn';
  }

  @override
  String get photoTakePhoto => 'Foto maken';

  @override
  String get photoChooseFromGallery => 'Kiezen uit galerij';

  @override
  String get photoRemoveImage => 'Afbeelding verwijderen';

  @override
  String get shareAsText => 'Tekst';

  @override
  String get shareAsImage => 'Afbeelding';

  @override
  String get shareAsFile => 'Delen als bestand';

  @override
  String get shareQrCode => 'QR-code recept';

  @override
  String get languageSystem => 'Systeemstandaard';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get scalingOriginal => 'Origineel';

  @override
  String get scalingHalf => 'Half';

  @override
  String get scalingDouble => 'Dubbel';

  @override
  String get scalingTriple => 'Drievoudig';

  @override
  String get scalingCustom => 'Aangepast';

  @override
  String scalingServings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count porties',
      one: '1 portie',
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
  String get tagsTitle => 'Labels';

  @override
  String get tagsSelect => 'Labels selecteren';

  @override
  String get tagsNoTags => 'Geen labels';

  @override
  String get tagsCreate => 'Label aanmaken';

  @override
  String get tagsCreateNew => 'Nieuw label aanmaken';

  @override
  String get tagsEnterName => 'Labelnaam';

  @override
  String get tagsSearch => 'Labels zoeken...';

  @override
  String get tagsSuggested => 'Aanbevolen labels';

  @override
  String get tagsRecent => 'Recent gebruikt';

  @override
  String get tagsAll => 'Alle labels';

  @override
  String get tagVegetarian => 'Vegetarisch';

  @override
  String get tagVegan => 'Veganistisch';

  @override
  String get tagGlutenFree => 'Glutenvrij';

  @override
  String get tagDairyFree => 'Zuivelvrij';

  @override
  String get tagNutFree => 'Notenvrij';

  @override
  String get tagLowCarb => 'Weinig koolhydraten';

  @override
  String get tagKeto => 'Keto';

  @override
  String get tagPaleo => 'Paleo';

  @override
  String get tagWhole30 => 'Whole30';

  @override
  String get tagQuick => 'Snel';

  @override
  String get tagEasy => 'Makkelijk';

  @override
  String get tagHealthy => 'Gezond';

  @override
  String get tagComfortFood => 'Troosteten';

  @override
  String get tagFamilyFriendly => 'Gezinsvriendelijk';

  @override
  String get tagKidFriendly => 'Kindvriendelijk';

  @override
  String get tagMealPrep => 'Maaltijdvoorbereiding';

  @override
  String get tagOnePot => 'Eén pot';

  @override
  String get tagInstantPot => 'Instant Pot';

  @override
  String get tagSlowCooker => 'Slowcooker';

  @override
  String get tagAirFryer => 'Airfryer';

  @override
  String get tagGrill => 'Grill';

  @override
  String get tagBBQ => 'BBQ';

  @override
  String get tagHoliday => 'Feestdagen';

  @override
  String get tagParty => 'Feest';

  @override
  String get tagBudget => 'Budgetvriendelijk';

  @override
  String get tagSpicy => 'Pittig';

  @override
  String get tagSweet => 'Zoet';

  @override
  String get tagSavory => 'Hartig';

  @override
  String get tagLight => 'Licht';

  @override
  String get tagHearty => 'Stevig';

  @override
  String get tagSummer => 'Zomer';

  @override
  String get tagWinter => 'Winter';

  @override
  String get tagFall => 'Herfst';

  @override
  String get tagSpring => 'Lente';

  @override
  String get settingsImagePlaceholders => 'Standaardafbeeldingen';

  @override
  String get settingsImagePlaceholdersSubtitle => 'Kies wat er wordt weergegeven als afbeeldingen ontbreken';

  @override
  String get settingsQuickAccessSubtitle => 'Snelle toegang configureren';

  @override
  String get settingsManageCoursesSubtitle => 'Gangen toevoegen, bewerken of verwijderen';

  @override
  String get settingsManageCategoriesSubtitle => 'Categorieën toevoegen, bewerken of verwijderen';

  @override
  String get settingsShoppingCategories => 'Boodschappencategorieën';

  @override
  String get settingsShoppingCategoriesSubtitle => 'Items per afdeling organiseren';

  @override
  String get shoppingIngredientMappings => 'Ingrediëntmappings';

  @override
  String shoppingPriority(int priority) {
    return 'Prioriteit: $priority';
  }

  @override
  String get shoppingAddCategory => 'Categorie toevoegen';

  @override
  String get shoppingEditCategory => 'Categorie bewerken';

  @override
  String get shoppingDeleteCategory => 'Categorie verwijderen?';

  @override
  String shoppingDeleteCategoryMessage(String name) {
    return 'Categorie \"$name\" verwijderen? Items worden ongecategoriseerd.';
  }

  @override
  String get shoppingCategoryName => 'Naam';

  @override
  String get shoppingSearchIngredients => 'Ingrediënten zoeken...';

  @override
  String shoppingMappingsInfo(int count) {
    return 'Tik op categorie om locatie te wijzigen. ($count mappings)';
  }

  @override
  String shoppingCategoryFor(String ingredient) {
    return 'Categorie voor \"$ingredient\"';
  }

  @override
  String shoppingMovedTo(String ingredient, String category) {
    return '\"$ingredient\" verplaatst naar $category';
  }

  @override
  String shoppingResetToDefault(String ingredient) {
    return '\"$ingredient\" hersteld naar standaard';
  }

  @override
  String get actionReset => 'Herstellen';

  @override
  String shoppingMappingMoved(String ingredient, String category) {
    return '\"$ingredient\" verplaatst naar $category';
  }

  @override
  String shoppingMappingReset(String ingredient) {
    return '\"$ingredient\" hersteld naar standaard';
  }

  @override
  String get addPhoto => 'Foto toevoegen';

  @override
  String get addPhotoSubtitle => 'Tik om te selecteren uit galerij of camera';

  @override
  String get viewAllRecipes => 'Alle recepten bekijken';

  @override
  String recipesTotal(int count) {
    return '$count recepten in totaal';
  }

  @override
  String get coursesTitle => 'Gangen';

  @override
  String get categoriesTitle => 'Categorieën';

  @override
  String get courseBrunch => 'Brunch';

  @override
  String get courseMainDish => 'Hoofdgerecht';

  @override
  String get courseSideDish => 'Bijgerecht';

  @override
  String get courseSauce => 'Saus';

  @override
  String get courseBread => 'Brood';

  @override
  String get categoryBean => 'Peulvruchten';

  @override
  String get categoryBread => 'Brood';

  @override
  String get categoryBurritoTaco => 'Burrito/Taco';

  @override
  String get categoryCasserole => 'Ovenschotel';

  @override
  String get categoryChickenSteakMeat => 'Kip/Biefstuk/Vlees';

  @override
  String get categoryDessert => 'Dessert';

  @override
  String get categoryFish => 'Vis';

  @override
  String get categoryFruit => 'Fruit';

  @override
  String get categoryPasta => 'Pasta';

  @override
  String get categoryPizza => 'Pizza';

  @override
  String get categoryPork => 'Varkensvlees';

  @override
  String get categoryRice => 'Rijst';

  @override
  String get categorySandwich => 'Broodje';

  @override
  String get categorySeafood => 'Zeevruchten';

  @override
  String get categorySoup => 'Soep';

  @override
  String get categoryVegetable => 'Groente';

  @override
  String get or => 'of';

  @override
  String get and => 'en';

  @override
  String get wordOf => 'van';

  @override
  String get items => 'items';

  @override
  String get more => 'meer';

  @override
  String get less => 'minder';

  @override
  String get all => 'Alles';

  @override
  String get none => 'Geen';

  @override
  String get other => 'Overig';

  @override
  String get custom => 'Aangepast';

  @override
  String get defaultValue => 'Standaard';

  @override
  String get required => 'Verplicht';

  @override
  String get optional => 'Optioneel';

  @override
  String get photoChooseGallery => 'Kiezen uit galerij';

  @override
  String get importFirstRecipe => 'Import First';

  @override
  String get importAllRecipes => 'Import All';

  @override
  String get parseRecipe => 'Parse Recipe';

  @override
  String get shareRecipe => 'Recept delen';

  @override
  String get shareExport => 'Exporteren';

  @override
  String shareServings(int count) {
    return 'Porties: $count';
  }

  @override
  String sharePrep(int minutes) {
    return 'Prep: $minutes min';
  }

  @override
  String shareCook(int minutes) {
    return 'Kooktijd: $minutes min';
  }

  @override
  String get shareFromApp => 'Gedeeld vanuit Recipe Spellbook ✨';

  @override
  String get shareCreatingCard => 'Receptkaart aanmaken...';

  @override
  String shareCheckRecipe(String title) {
    return 'Bekijk dit recept: $title';
  }

  @override
  String shareErrorImage(String error) {
    return 'Fout bij aanmaken afbeelding: $error';
  }

  @override
  String get editItem => 'Item bewerken';

  @override
  String get selectAll => 'Alles selecteren';

  @override
  String get selectNone => 'Niets selecteren';

  @override
  String get viewPlanner => 'View Planner';

  @override
  String get planNow => 'Plan Now';

  @override
  String get loadingText => 'Laden...';

  @override
  String get errorText => 'Fout';

  @override
  String get errorLoadingMeals => 'Fout bij laden maaltijden';

  @override
  String get readingImage => 'Afbeelding lezen...';

  @override
  String get parsingRecipe => 'Recept verwerken...';

  @override
  String get noTextInImage => 'Geen tekst gevonden in afbeelding';

  @override
  String failedProcessImage(String error) {
    return 'Fout bij verwerken afbeelding: $error';
  }

  @override
  String get cookingModeExit => 'Kookmodus verlaten';

  @override
  String cookingModeStep(int current, int total) {
    return 'Stap $current van $total';
  }

  @override
  String get cookingModePrevious => 'Vorige';

  @override
  String get cookingModeNext => 'Volgende';

  @override
  String get cookingModeFinish => 'Voltooien';

  @override
  String get cookingModeCompleted => 'Recept voltooid!';

  @override
  String get cookingModeGreatJob => 'Goed gedaan! Eet smakelijk.';

  @override
  String get mealPlanBreakfast => 'Ontbijt';

  @override
  String get mealPlanLunch => 'Lunch';

  @override
  String get mealPlanDinner => 'Diner';

  @override
  String get mealPlanSnack => 'Snack';

  @override
  String get mealPlanAddMeal => 'Maaltijd toevoegen';

  @override
  String get mealPlanRemove => 'Verwijderen uit plan';

  @override
  String get mealPlanNoMeals => 'Geen maaltijden gepland';

  @override
  String get mealPlanTapToAdd => 'Tik op + om een maaltijd toe te voegen';

  @override
  String get thisWeek => 'Deze week';

  @override
  String get itemName => 'Itemnaam';

  @override
  String get addToShoppingList => 'Toevoegen aan boodschappenlijst';

  @override
  String get addToList => 'Toevoegen aan lijst';

  @override
  String addedItemsToList(int count) {
    return '$count items toegevoegd aan lijst';
  }

  @override
  String get scanToImport => 'Scannen om recept te importeren';

  @override
  String xOfY(int current, int total) {
    return '$current van $total';
  }

  @override
  String addItems(int count) {
    return '$count items toevoegen';
  }

  @override
  String failedToParse(String error) {
    return 'Verwerken mislukt: $error';
  }

  @override
  String failedToImport(String error) {
    return 'Importeren mislukt: $error';
  }

  @override
  String get groupBy => 'Groeperen op';

  @override
  String get cookbookHint => 'Tik om te selecteren • Lang tikken om te bewerken';

  @override
  String get rename => 'Hernoemen';

  @override
  String get renameCookbook => 'Kookboek hernoemen';

  @override
  String get seeAll => 'Alles bekijken';

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
  String get syncSection => 'Synchronisatie';

  @override
  String get cloudSync => 'Cloudsynchronisatie';

  @override
  String get comingSoon => 'Binnenkort';

  @override
  String get resetApp => 'App resetten';

  @override
  String get resetAppSubtitle => 'Alle gegevens permanent verwijderen';

  @override
  String get trashSubtitle => 'Verwijderde recepten (30 dagen bewaard)';

  @override
  String get importRecipeTitle => 'Recept importeren';

  @override
  String get importSocialMedia => 'Importeer je recepten van sociale media of elke website.';

  @override
  String get pasteRecipeUrl => 'Recept-URL plakken';

  @override
  String get orDivider => 'OF';

  @override
  String get fileOption => 'Bestand';

  @override
  String get imageOption => 'Afbeelding';

  @override
  String get pasteOption => 'Plakken';

  @override
  String get supportedFormats => 'Ondersteunt Paprika, Mela, JSON, ZIP';

  @override
  String get pasteRecipeTitle => 'Recept plakken';

  @override
  String get pasteRecipeHint => 'Plak je recept hier...';

  @override
  String get quickAccessHelpIntro => 'Deze badges geven aan waarom recepten hier verschijnen:';

  @override
  String get quickAccessHelpMealPlan => 'Gepland voor vandaag';

  @override
  String get quickAccessHelpPinned => 'Je hebt dit recept vastgezet';

  @override
  String get quickAccessHelpRecent => 'Recent bekeken';

  @override
  String get openCalendar => 'Kalender openen';

  @override
  String get editNotes => 'Notities bewerken';

  @override
  String get addNotesHint => 'Notities toevoegen...';

  @override
  String get moveToAnotherDay => 'Naar andere dag verplaatsen';

  @override
  String get addToPlan => 'Toevoegen aan plan';

  @override
  String importBulkQuestion(int count) {
    return 'Wil je alle $count recepten importeren of individueel selecteren?';
  }

  @override
  String get importingRecipes => 'Recepten importeren...';

  @override
  String importedRecipesCount(int count) {
    return '$count recepten geïmporteerd';
  }

  @override
  String get extractingArchive => 'Archief uitpakken...';

  @override
  String get themeSpellbook => 'Spellbook';

  @override
  String get themeForest => 'Bos';

  @override
  String get themeOcean => 'Oceaan';

  @override
  String get themeSunset => 'Zonsondergang';

  @override
  String get themeMidnight => 'Middernacht';

  @override
  String get themeRose => 'Roos';

  @override
  String get colorTheme => 'Kleurthema';

  @override
  String get colorThemeSubtitle => 'Kies het kleurpalet';

  @override
  String get preview => 'Voorbeeld';

  @override
  String get previewPrimary => 'Primair';

  @override
  String get previewSecondary => 'Secundair';

  @override
  String get previewTertiary => 'Tertiair';

  @override
  String get previewError => 'Fout';

  @override
  String get placeholderDescription => 'Kies wat er wordt weergegeven wanneer recepten of kookboeken geen afbeeldingen hebben.';

  @override
  String get recipePlaceholders => 'Receptafbeeldingen';

  @override
  String get cookbookPlaceholders => 'Kookboekafbeeldingen';

  @override
  String get defaultImages => 'Standaardafbeeldingen';

  @override
  String get defaultImagesDescription => 'Default app artwork for recipes and cookbooks';

  @override
  String get themeBased => 'Op thema gebaseerd';

  @override
  String get themeBasedDescription => 'Verloop met logo op basis van je thema';

  @override
  String get groupBySection => 'Op afdeling';

  @override
  String get groupByRecipe => 'Op recept';

  @override
  String get groupByUngrouped => 'Niet gegroepeerd';

  @override
  String get copyAsText => 'Kopiëren als tekst';

  @override
  String get printList => 'Lijst afdrukken';

  @override
  String get manageLists => 'Lijsten beheren';

  @override
  String get newList => 'Nieuw';

  @override
  String get newShoppingList => 'Nieuwe boodschappenlijst';

  @override
  String get listNameHint => 'List name';

  @override
  String get recipeLayoutSetting => 'Indeling';

  @override
  String get recipeLayoutSettingSubtitle => 'Kies hoe recepten worden weergegeven';

  @override
  String get layoutTabbedOption => 'Tabbladweergave';

  @override
  String get layoutStackedOption => 'Gestapelde weergave';

  @override
  String get nutrientsTitle => 'Voedingswaarden';

  @override
  String get nutrientsSubtitle => 'Voedingsinformatie per portie';

  @override
  String get addNutrients => 'Voedingsinformatie toevoegen';

  @override
  String get calculateNutrients => 'Berekenen van ingrediënten';

  @override
  String get nutrientsDisclaimer => 'Voedingswaarden zijn schattingen.';

  @override
  String get calories => 'Calorieën';

  @override
  String get protein => 'Eiwit';

  @override
  String get carbohydrates => 'Koolhydraten';

  @override
  String get fat => 'Vet';

  @override
  String get fiber => 'Vezels';

  @override
  String get sugar => 'Suiker';

  @override
  String get sodium => 'Natrium';

  @override
  String get cholesterol => 'Cholesterol';

  @override
  String get saturatedFat => 'Verzadigd vet';

  @override
  String get transFat => 'Transvet';

  @override
  String get servingSize => 'Portiegrootte';

  @override
  String get perServing => 'Per portie';

  @override
  String get calculatingNutrients => 'Voedingswaarden berekenen...';

  @override
  String get nutrientsCalculated => 'Voedingswaarden berekend';

  @override
  String nutrientsFailed(String error) {
    return 'Kan voedingswaarden niet berekenen: $error';
  }

  @override
  String get premiumFeature => 'Premium functie';

  @override
  String get premiumNutrientsDescription => 'Automatische voedingsberekening vereist een premium abonnement';

  @override
  String get exportCurrentCookbook => 'Huidig kookboek exporteren';

  @override
  String get exporting => 'Exporteren...';

  @override
  String get exportAllCookbooks => 'Alle kookboeken exporteren';

  @override
  String get importing => 'Importeren...';

  @override
  String get importFromJson => 'Importeren van JSON';

  @override
  String get importFromJsonSubtitle => 'Back-upbestand selecteren';

  @override
  String get aboutDescription => 'Je magische metgezel voor het organiseren, plannen en koken van heerlijke maaltijden.';

  @override
  String get madeWithLove => 'Gemaakt met ❤️ voor koks over de hele wereld';

  @override
  String get resetAppWarning => 'Dit verwijdert al je recepten, maaltijdplannen, boodschappenlijsten en instellingen permanent.';

  @override
  String get actionContinue => 'Doorgaan';

  @override
  String get finalConfirmation => 'Definitieve bevestiging';

  @override
  String get typeDeleteToConfirm => 'Typ VERWIJDER ter bevestiging';

  @override
  String get typeDeleteHint => 'VERWIJDER';

  @override
  String get resetScopeLocal => 'lokale gegevens';

  @override
  String get resetScopeCloud => 'cloudgegevens';

  @override
  String get resetScopeAll => 'alle gegevens en instellingen';

  @override
  String get resetEverything => 'Alles resetten';

  @override
  String get resettingApp => 'Resetten...';

  @override
  String get appResetSuccess => 'App gereset';

  @override
  String get resetFailed => 'Resetten mislukt';

  @override
  String get successAdded => 'Succesvol toegevoegd';

  @override
  String get selectToday => 'Vandaag selecteren';

  @override
  String get selectTomorrow => 'Morgen selecteren';

  @override
  String get addedManually => 'Handmatig toegevoegd';

  @override
  String get unknownRecipe => 'Onbekend recept';

  @override
  String get shoppingListEmpty => 'Je boodschappenlijst is leeg';

  @override
  String get shoppingListEmptyHint => 'Voeg items toe of importeer vanuit recepten';

  @override
  String get settingsKitchenBuddyActive => 'Magische tekst oproepen...';

  @override
  String get shoppingCheckAll => 'Alles aanvinken';

  @override
  String get shoppingUncheckAll => 'Alles uitvinken';

  @override
  String get shoppingManageLists => 'Lijsten beheren';

  @override
  String get shoppingNewList => 'Nieuwe boodschappenlijst';

  @override
  String get shoppingListName => 'Lijstnaam';

  @override
  String get shoppingLists => 'Boodschappenlijsten';

  @override
  String get shoppingRenameList => 'Lijst hernoemen';

  @override
  String get shoppingDeleteList => 'Lijst verwijderen?';

  @override
  String get categoryProduce => 'Groente & Fruit';

  @override
  String get categoryDairy => 'Zuivel';

  @override
  String get categoryMeat => 'Vlees';

  @override
  String get categoryBakery => 'Bakkerij';

  @override
  String get categoryFrozen => 'Diepvries';

  @override
  String get categoryBeverages => 'Dranken';

  @override
  String get categoryPantry => 'Voorraadkast';

  @override
  String get categorySpices => 'Kruiden';

  @override
  String get categoryInternational => 'Internationaal';

  @override
  String get categorySnacks => 'Snacks';

  @override
  String get categoryOther => 'Overig';

  @override
  String get from => 'van';

  @override
  String get deleted => 'verwijderd';

  @override
  String get currently => 'Momenteel in';

  @override
  String get autoDetect => 'Automatisch detecteren';

  @override
  String get category => 'Categorie';

  @override
  String get actionNew => 'Nieuw';

  @override
  String get actionCreate => 'Aanmaken';

  @override
  String get tagsAdd => 'Label toevoegen';

  @override
  String get tagsSearchOrCreate => 'Label zoeken of aanmaken...';

  @override
  String get tagsNoResults => 'Geen labels gevonden';

  @override
  String get color => 'Kleur';

  @override
  String get icon => 'Icoon';

  @override
  String get nutritionTitle => 'Voeding';

  @override
  String get nutritionEmpty => 'Geen voedingsgegevens';

  @override
  String get nutritionEmptyHint => 'Bewerk dit recept en bereken voeding vanuit de ingrediënten';

  @override
  String get scaled => 'geschaald';

  @override
  String get nutritionCalculate => 'Voeding berekenen';

  @override
  String get nutritionCalculating => 'Berekenen...';

  @override
  String get nutritionMatchingIngredients => 'Ingrediënten koppelen aan USDA-database';

  @override
  String get nutritionCalculationFailed => 'Kan voeding niet berekenen';

  @override
  String get nutritionDisclaimer => 'Voedingswaarden zijn schattingen op basis van USDA-gegevens.';

  @override
  String get nutritionPerServing => 'Per portie';

  @override
  String nutritionServings(int count) {
    return '$count porties';
  }

  @override
  String get nutritionIngredientBreakdown => 'Uitsplitsing per ingrediënt';

  @override
  String get nutritionIngredientsMatched => 'Gekoppelde ingrediënten';

  @override
  String nutritionMatchedCount(int matched, int total) {
    return '$matched van $total gekoppeld';
  }

  @override
  String nutritionUncertainCount(int count) {
    return '$count te controleren';
  }

  @override
  String get nutritionUncertain => 'koppeling controleren';

  @override
  String get nutritionNotFound => 'Geen koppeling — tik om te zoeken';

  @override
  String get nutritionRecalculate => 'Herberekenen';

  @override
  String get nutritionOverwriteTitle => 'Voedingsgegevens overschrijven?';

  @override
  String get nutritionOverwriteMessage => 'Dit recept heeft al voedingsgegevens. Wil je herberekenen?';

  @override
  String get nutritionCalculated => 'Voeding succesvol berekend';

  @override
  String get nutritionSave => 'Voeding opslaan';

  @override
  String get nutritionSelectFood => 'USDA-voedingsmiddel selecteren';

  @override
  String get nutritionSearchFood => 'Voedingsmiddelen zoeken...';

  @override
  String get nutritionNoResults => 'Geen resultaten';

  @override
  String get nutritionCalories => 'Calorieën';

  @override
  String get nutritionProtein => 'Eiwit';

  @override
  String get nutritionCarbs => 'Koolhydraten';

  @override
  String get nutritionFat => 'Totaal vet';

  @override
  String get nutritionSaturatedFat => 'Verzadigd vet';

  @override
  String get nutritionTransFat => 'Transvet';

  @override
  String get nutritionFiber => 'Voedingsvezels';

  @override
  String get nutritionSugar => 'Suikers';

  @override
  String get nutritionCholesterol => 'Cholesterol';

  @override
  String get nutritionSodium => 'Natrium';

  @override
  String get nutritionPotassium => 'Kalium';

  @override
  String get nutritionCalcium => 'Calcium';

  @override
  String get nutritionIron => 'IJzer';

  @override
  String get nutritionVitaminA => 'Vitamine A';

  @override
  String get nutritionVitaminC => 'Vitamine C';

  @override
  String get nutritionVitaminD => 'Vitamine D';

  @override
  String get layoutInfoText => 'Voedingsgegevens verschijnen in beide indelingen.';

  @override
  String get settingsManageTagsSubtitle => 'Labels maken en organiseren';

  @override
  String get nutritionTotal => 'Totaal';

  @override
  String get nutritionAutoCalculate => 'Automatisch berekenen';

  @override
  String get nutritionManualEntry => 'Handmatige invoer';

  @override
  String get nutritionManualEntryTitle => 'Bekende waarden invoeren';

  @override
  String get nutritionManualEntryDescription => 'Als je de exacte waarden kent, voer ze dan hier in.';

  @override
  String get nutritionMainNutrients => 'Hoofdvoedingsstoffen';

  @override
  String get nutritionOtherNutrients => 'Andere voedingsstoffen';

  @override
  String get nutritionEnterAtLeastOne => 'Voer minimaal calorieën of een macronutriënt in';

  @override
  String get nutritionHowToFix => 'Hoe te herstellen';

  @override
  String get nutritionHowToImproveAccuracy => 'Hoe nauwkeurigheid te verbeteren';

  @override
  String get nutritionEditIngredient => 'Ingrediënt bewerken';

  @override
  String get nutritionSearchUsda => 'USDA doorzoeken';

  @override
  String get nutritionEnterManually => 'Handmatig invoeren';

  @override
  String get nutritionManualIngredientHint => 'Voer de voedingswaarden voor dit ingrediënt in.';

  @override
  String get nutritionApplyManual => 'Handmatige waarden toepassen';

  @override
  String get nutritionTotalRecipe => 'Totale voeding recept';

  @override
  String get nutritionMatchRate => 'Koppelingspercentage';

  @override
  String get allergySettingsTitle => 'Allergieënstellingen';

  @override
  String get allergyInfoText => 'Selecteer je allergenen. Recipe Spellbook waarschuwt je wanneer recepten deze bevatten.';

  @override
  String allergySelectedCount(int count) {
    return '$count allergenen geselecteerd';
  }

  @override
  String get allergySelectAll => 'Alles selecteren';

  @override
  String get allergyClearAll => 'Alles wissen';

  @override
  String get allergyMajorTitle => 'Belangrijkste allergenen';

  @override
  String get allergyMajorSubtitle => 'Door de FDA erkende voedselallergenen';

  @override
  String get allergyAdditionalTitle => 'Aanvullende allergenen';

  @override
  String get allergyAdditionalSubtitle => 'Andere veelvoorkomende voedselgevoeligheden';

  @override
  String get allergyWillWarn => 'Je wordt gewaarschuwd voor dit allergeen';

  @override
  String get allergyWarningTitle => '⚠️ Allergiewaarschuwing';

  @override
  String get allergyWarningTitlePossible => '⚠️ Mogelijke allergenen';

  @override
  String get allergyContains => 'Bevat:';

  @override
  String get allergyMayContain => 'Kan bevatten:';

  @override
  String get allergyContainsAllergens => 'Bevat allergenen';

  @override
  String get allergyManageSettings => 'Allergieënstellingen beheren';

  @override
  String get allergyDetailsTitle => 'Allergenendetails';

  @override
  String get settingsAllergies => 'Allergieën';

  @override
  String get settingsAllergiesSubtitle => 'Allergeenwaarschuwingen configureren';

  @override
  String get allergenMilk => 'Melk/Zuivel';

  @override
  String get allergenEggs => 'Eieren';

  @override
  String get allergenFish => 'Vis';

  @override
  String get allergenShellfish => 'Schaaldieren';

  @override
  String get allergenTreeNuts => 'Boomnotenoten';

  @override
  String get allergenPeanuts => 'Pinda\'s';

  @override
  String get allergenWheat => 'Tarwe/Gluten';

  @override
  String get allergenSoy => 'Soja';

  @override
  String get allergenSesame => 'Sesam';

  @override
  String get allergenMustard => 'Mosterd';

  @override
  String get allergenCelery => 'Selderij';

  @override
  String get allergenLupin => 'Lupine';

  @override
  String get allergenMollusks => 'Weekdieren';

  @override
  String get allergenSulfites => 'Sulfieten';

  @override
  String get allergenCorn => 'Maïs';

  @override
  String get allergenNightshades => 'Nachtschaden';

  @override
  String get nutritionCopyFromAuto => 'Kopiëren van automatische berekening';

  @override
  String get nutritionEstimatedDisclaimer => 'Waarden zijn geschat op basis van USDA-gegevens';

  @override
  String get actionDiscard => 'Verwijderen';

  @override
  String get unsavedChangesTitle => 'Niet-opgeslagen wijzigingen';

  @override
  String get unsavedChangesMessage => 'Je hebt niet-opgeslagen wijzigingen. Wil je ze opslaan?';

  @override
  String get tagsEmptyTitle => 'Geen labels';

  @override
  String get tagsEmptySubtitle => 'Maak labels aan om je recepten te organiseren.';

  @override
  String get tagsLoadDefaults => 'Standaardlabels laden';

  @override
  String get tagsAddNew => 'Label toevoegen';

  @override
  String get tagsEdit => 'Label bewerken';

  @override
  String get tagsDelete => 'Label verwijderen';

  @override
  String tagsDeleteConfirm(String name) {
    return 'Weet je zeker dat je \"$name\" wilt verwijderen?';
  }

  @override
  String get tagsNameLabel => 'Labelnaam';

  @override
  String get tagsIconLabel => 'Icoon (emoji)';

  @override
  String get tagsColorLabel => 'Kleur';

  @override
  String get settingsKitchenBuddyEnabled => 'Earn coins and dress up your buddy!';

  @override
  String get settingsRecipeLayoutSubtitle => 'Receptweergave aanpassen';

  @override
  String get shareLink => 'Link';

  @override
  String get shareDocument => 'PDF';

  @override
  String get sharePrint => 'Afdrukken';

  @override
  String get shareLinkDescription => 'Deel een link zodat anderen dit recept kunnen bekijken.';

  @override
  String get shareLinkNote => 'Ontvangers hebben Recipe Spellbook nodig of kunnen het op het web bekijken.';

  @override
  String get shareCreatingDocument => 'Document aanmaken...';

  @override
  String get editLayoutTitle => 'Bewerkingsindeling';

  @override
  String get editLayoutStacked => 'Gestapeld';

  @override
  String get editLayoutTabbed => 'Tabbladen';

  @override
  String get editLayoutStackedDesc => 'Alle secties in een scrollbare weergave';

  @override
  String get editLayoutTabbedDesc => 'Aparte tabbladen voor details, ingrediënten, instructies';

  @override
  String get tabDetails => 'Details';

  @override
  String get tabIngredients => 'Ingrediënten';

  @override
  String get tabInstructions => 'Instructies';

  @override
  String get stepImageAdd => 'Afbeelding toevoegen';

  @override
  String get stepImageChange => 'Afbeelding wijzigen';

  @override
  String get stepImageRemove => 'Afbeelding verwijderen';

  @override
  String get stepTimer => 'Timer';

  @override
  String stepTimerMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get recipeAddToCookbook => 'Toevoegen aan kookboek';

  @override
  String get recipeMoveToTrash => 'Naar prullenbak verplaatsen';

  @override
  String get tagsEmpty => 'Geen labels';

  @override
  String get nutritionPerServingLabel => 'Per portie';

  @override
  String get nutritionTotalLabel => 'Volledig recept';

  @override
  String get trendingRecipes => 'Populaire recepten';

  @override
  String get addShortcut => 'Recipe Spellbook-snelkoppeling toevoegen';

  @override
  String get addShortcutSubtitle => 'Importeer recepten met één gebaar';

  @override
  String get importGuides => 'Lees onze importgidsen';

  @override
  String get useOnDesktop => 'Recipe Spellbook gebruiken op desktop';

  @override
  String get inviteFriends => 'Vrienden uitnodigen';

  @override
  String get inviteFriendsTitle => 'Recipe Spellbook delen';

  @override
  String get inviteFriendsSubtitle => 'Nodig vrienden en familie uit om samen te koken!';

  @override
  String get shareApp => 'App delen';

  @override
  String get maybeLater => 'Misschien later';

  @override
  String get createAccount => 'Account aanmaken';

  @override
  String get upgradeToPremium => 'Upgraden naar Premium';

  @override
  String get premiumSubtitle => 'Ontgrendel synchronisatie, onbeperkte recepten en meer';

  @override
  String get leaderboards => 'Ranglijsten';

  @override
  String get achievements => 'Prestaties';

  @override
  String get cookingStats => 'Kookstatistieken';

  @override
  String get stepByStepGuides => 'Stap-voor-stap gidsen';

  @override
  String get importGuidesSubtitle => 'Leer importeren vanuit je favoriete apps en sites';

  @override
  String get importFromOtherApps => 'Importeren vanuit andere apps';

  @override
  String get orderOnline => 'Online bestellen';

  @override
  String get helpTitle => 'Help';

  @override
  String get navMenu => 'Menu';

  @override
  String get mealPlanTitle => 'Mijn maaltijdplan';

  @override
  String get noRecipesYet => 'Nog geen recepten';

  @override
  String get breakfast => 'Ontbijt';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Diner';

  @override
  String get snack => 'Snack';

  @override
  String get allergenGluten => 'Gluten';

  @override
  String get allergenChocolate => 'Chocolade & Cacao';

  @override
  String get allergenCaffeine => 'Cafeïne';

  @override
  String get allergenAlcohol => 'Alcohol';

  @override
  String get allergenCitrus => 'Citrus';

  @override
  String get allergenStoneFruits => 'Steenvruchten';

  @override
  String get allergenCoconut => 'Kokosnoot';

  @override
  String get allergenGarlic => 'Knoflook';

  @override
  String get allergenOnion => 'Ui';

  @override
  String get allergenMushrooms => 'Paddenstoelen';

  @override
  String get allergenAvocado => 'Avocado';

  @override
  String get allergenBanana => 'Banaan';

  @override
  String get allergenKiwi => 'Kiwi';

  @override
  String get allergenLatexFoods => 'Latex-kruisreactiviteit';

  @override
  String get allergenFodmap => 'Hoog FODMAP';

  @override
  String get allergenHistamine => 'Hoge histamine';

  @override
  String get allergenSalicylates => 'Salicylaten';

  @override
  String get allergenMsg => 'MSG';

  @override
  String get allergenRedMeat => 'Rood vlees (Alpha-gal)';

  @override
  String get allergenGelatin => 'Gelatine';

  @override
  String get allergyWarningContains => 'Bevat';

  @override
  String get allergyDismissForRecipe => 'Negeren voor dit recept';

  @override
  String get allergyDismissUndo => 'Ongedaan maken';

  @override
  String get allergyWarningDismissed => 'Waarschuwing genegeerd voor dit recept';

  @override
  String get scaleCustom => 'Aangepast';

  @override
  String get scaleCustomTitle => 'Aangepaste schaal';

  @override
  String get scaleCustomHint => 'Voer een getal in (bijv. 0,75 voor ¾, 2,5 voor 2½)';

  @override
  String get scaleApply => 'Toepassen';

  @override
  String get addStep => 'Stap toevoegen';

  @override
  String get noInstructionsYet => 'Nog geen instructies';

  @override
  String get addFirstStep => 'Eerste stap toevoegen';

  @override
  String get enterInstruction => 'Voer instructie in...';

  @override
  String get addStepImage => 'Afbeelding toevoegen aan stap';

  @override
  String get removeStep => 'Stap verwijderen';

  @override
  String get plannerNoMeals => 'Geen maaltijden gepland';

  @override
  String get plannerAddMealHint => 'Tik op + om een maaltijd toe te voegen';

  @override
  String plannerMealAdded(String recipe, String mealType) {
    return '$recipe toegevoegd aan $mealType';
  }

  @override
  String get plannerShareMealPlan => 'Maaltijdplan delen';

  @override
  String get plannerAddWeekToShopping => 'Week toevoegen aan boodschappenlijst';

  @override
  String get plannerClearWeek => 'Deze week wissen';

  @override
  String get plannerClearWeekConfirm => 'Dit verwijdert alle geplande maaltijden van deze week.';

  @override
  String get plannerWeekCleared => 'Week gewist';

  @override
  String get plannerGoToToday => 'Naar vandaag gaan';

  @override
  String get plannerAddAnother => 'Nog een maaltijd toevoegen';

  @override
  String get plannerSearchRecipes => 'Recepten zoeken...';

  @override
  String get mealTypeBreakfast => 'Ontbijt';

  @override
  String get mealTypeLunch => 'Lunch';

  @override
  String get mealTypeDinner => 'Diner';

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
  String get shoppingBySection => 'Op afdeling';

  @override
  String get shoppingByRecipe => 'Op recept';

  @override
  String get shoppingUngrouped => 'Niet gegroepeerd';

  @override
  String get shoppingOrderOnline => 'Online bestellen';

  @override
  String get shoppingEditItem => 'Item bewerken';

  @override
  String get shoppingItemName => 'Itemnaam';

  @override
  String get shoppingSelectCategory => 'Categorie selecteren';

  @override
  String get shoppingAddedManually => 'Handmatig toegevoegd';

  @override
  String get shoppingEmptyList => 'Je lijst is leeg';

  @override
  String get shoppingEmptyHint => 'Tik op + om items toe te voegen';

  @override
  String get shoppingAddHint => 'Druk op Enter om toe te voegen, typ dan het volgende';

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
    return 'Importeren van $platform';
  }

  @override
  String importFromApp(String app) {
    return 'Importeren van $app';
  }

  @override
  String get helpAddingRecipes => 'Recepten toevoegen';

  @override
  String get helpAddingRecipesDesc => 'Tik op + in een kookboek om een recept toe te voegen.';

  @override
  String get helpImporting => 'Importeren vanuit apps';

  @override
  String get helpImportingDesc => 'Deel een recept vanuit Instagram, TikTok of een website.';

  @override
  String get helpMealPlanning => 'Maaltijdplanning';

  @override
  String get helpMealPlanningDesc => 'Tik op het tabblad Planner om je maaltijden voor de week te plannen.';

  @override
  String get helpShopping => 'Boodschappenlijsten';

  @override
  String get helpShoppingDesc => 'Voeg ingrediënten toe aan je lijst. Items zijn georganiseerd per afdeling.';

  @override
  String get helpSyncing => 'Synchronisatie';

  @override
  String get helpSyncingDesc => 'Cloud sync komt binnenkort!';

  @override
  String get helpContactUs => 'Neem contact op';

  @override
  String get helpContactUsDesc => 'Vragen? Schrijf ons op support@recipespellbook.com';

  @override
  String get navCommunity => 'Community';

  @override
  String get navComingSoon => 'Binnenkort';

  @override
  String get mealPlanButton => 'Maaltijdplan';

  @override
  String get groceriesButton => 'Boodschappen';

  @override
  String get shareButton => 'Delen';

  @override
  String get scaleRecipeButton => 'Schalen';

  @override
  String get convertUnitsButton => 'Omrekenen';

  @override
  String get allergyDismissTooltip => 'Waarschuwing negeren';

  @override
  String get allergyDisablePrompt => 'Deze waarschuwing permanent uitschakelen voor dit recept?';

  @override
  String get allergyDisabledForRecipe => 'Waarschuwing uitgeschakeld voor dit recept';

  @override
  String get allergyRestoreWarnings => 'Waarschuwingen herstellen';

  @override
  String get recipeDuplicated => 'Recept gedupliceerd';

  @override
  String get recipeDeleted => 'Recept naar prullenbak verplaatst';

  @override
  String get deleteRecipeTitle => 'Recept verwijderen';

  @override
  String get deleteRecipeConfirm => 'Weet je zeker dat je dit recept wilt verwijderen? Het wordt naar de prullenbak verplaatst.';

  @override
  String get addToShoppingListTitle => 'Toevoegen aan boodschappenlijst';

  @override
  String get viewList => 'Lijst bekijken';

  @override
  String get selectItems => 'Items selecteren';

  @override
  String addToListCount(int count) {
    return '$count items toevoegen';
  }

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nee';

  @override
  String get cancel => 'Annuleren';

  @override
  String get delete => 'Verwijderen';

  @override
  String get save => 'Opslaan';

  @override
  String get restore => 'Herstellen';

  @override
  String get unselectAll => 'Selectie opheffen';

  @override
  String get deleteStep => 'Stap verwijderen';

  @override
  String get deleteSteps => 'Stappen verwijderen';

  @override
  String get deleteStepConfirm => 'Deze stap verwijderen?';

  @override
  String deleteStepsConfirm(int count) {
    return '$count stappen verwijderen?';
  }

  @override
  String stepSelected(int count) {
    return '$count geselecteerd';
  }

  @override
  String get selectAllSteps => 'Alles selecteren';

  @override
  String get gradientBased => 'Op verloop gebaseerd';

  @override
  String get gradientBasedDescription => 'Kleurverloop van je thema';

  @override
  String get startCooking => 'Beginnen met koken';

  @override
  String get fontSizeLabel => 'Tekstgrootte';

  @override
  String krogerLoginDenied(String error) {
    return 'Kroger-aanmelding geweigerd: $error';
  }

  @override
  String get krogerNoAuthCode => 'Geen autorisatiecode ontvangen van Kroger.';

  @override
  String get krogerConnected => 'Kroger verbonden! Je kunt items rechtstreeks naar je winkelwagen sturen.';

  @override
  String get krogerConnectFailed => 'Verbinding met Kroger mislukt.';

  @override
  String get krogerConnecting => 'Verbinding maken met Kroger…';

  @override
  String get krogerExchanging => 'Autorisatie uitwisselen...';

  @override
  String get krogerConnectedTitle => 'Verbonden!';

  @override
  String get krogerConnectionFailed => 'Verbinding mislukt';

  @override
  String get goToShoppingList => 'Naar boodschappenlijst gaan';

  @override
  String get tryAgain => 'Opnieuw proberen';

  @override
  String get skipForNow => 'Voorlopig overslaan';

  @override
  String get skipDuplicates => 'Duplicaten overslaan';

  @override
  String get deselectAll => 'Selectie opheffen';

  @override
  String get duplicate => 'Dupliceren';

  @override
  String recipesImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recepten geïmporteerd',
      one: 'recept geïmporteerd',
    );
    return '$count $_temp0';
  }

  @override
  String importCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recepten',
      one: 'recept',
    );
    return '$count $_temp0 importeren';
  }

  @override
  String get productNotFound => 'Product niet gevonden';

  @override
  String barcodeNotFound(String barcode) {
    return 'Geen product gevonden voor barcode:\n$barcode';
  }

  @override
  String get manualEntryHint => 'Je kunt de productnaam handmatig invoeren.';

  @override
  String get scanAgain => 'Opnieuw scannen';

  @override
  String get enterManually => 'Handmatig invoeren';

  @override
  String get enterProductName => 'Productnaam invoeren';

  @override
  String get productName => 'Productnaam';

  @override
  String get scanBarcode => 'Barcode scannen';

  @override
  String get lookingUpProduct => 'Product opzoeken...';

  @override
  String get pointCameraBarcode => 'Richt je camera op een barcode';

  @override
  String get unknownProduct => 'Onbekend product';

  @override
  String get nutritionPer100g => 'Voeding (per 100g)';

  @override
  String get findRecipesWithThis => 'Recepten vinden met dit product';

  @override
  String get scanAnother => 'Nog een scannen';

  @override
  String get exportFormat => 'Exportformaat';

  @override
  String get gotIt => 'Begrepen';

  @override
  String get calendar => 'Kalender';

  @override
  String get today => 'Vandaag';

  @override
  String get shareMealPlan => 'Maaltijdplan delen';

  @override
  String get addWeekToShoppingList => 'Week toevoegen aan lijst';

  @override
  String get clearThisWeek => 'Deze week wissen?';

  @override
  String get clearWeekWarning => 'Dit verwijdert alle geplande maaltijden van deze week.';

  @override
  String get goToToday => 'Naar vandaag';

  @override
  String get addAnotherMeal => 'Nog een maaltijd toevoegen';

  @override
  String get meal => 'Maaltijd';

  @override
  String get noMealsPlanned => 'Geen maaltijden gepland';

  @override
  String get tapToAddMeal => 'Tik op + om toe te voegen';

  @override
  String get addMeal => 'Maaltijd toevoegen';

  @override
  String addToDay(String dayName) {
    return 'Toevoegen aan $dayName';
  }

  @override
  String get searchRecipes => 'Recepten zoeken...';

  @override
  String get noRecipesFound => 'Geen recepten gevonden';

  @override
  String get exitShoppingListGenerator => 'Lijstgenerator verlaten?';

  @override
  String get actionExit => 'Verlaten';

  @override
  String get shoppingListGenerator => 'Boodschappenlijstgenerator';

  @override
  String reviewAndAdd(int count) {
    return 'Bekijken en toevoegen ($count items)';
  }

  @override
  String addItemsToList(int count) {
    return '$count items toevoegen aan lijst';
  }

  @override
  String addedItemsToShoppingList(int count) {
    return '$count items toegevoegd aan boodschappenlijst';
  }

  @override
  String get createNewList => 'Nieuwe lijst aanmaken';

  @override
  String get listName => 'Lijstnaam';

  @override
  String get manage => 'Beheren';

  @override
  String get myPantry => 'Mijn voorraadkast';

  @override
  String get itemsAlwaysOnHand => 'Items altijd beschikbaar';

  @override
  String get whatToDelete => 'Wat wil je verwijderen?';

  @override
  String get localData => 'Lokale gegevens';

  @override
  String get localDataDesc => 'Recepten, kookboeken, maaltijdplannen, boodschappenlijsten op dit apparaat';

  @override
  String get allData => 'Alle gegevens';

  @override
  String get allDataDesc => 'Lokale gegevens en instellingen — volledige reset';

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
    return 'Dit verwijdert $scope permanent. Deze actie kan niet ongedaan worden gemaakt.';
  }

  @override
  String get dataResetComplete => 'Gegevens reset voltooid';

  @override
  String get noThanks => 'Nee bedankt';

  @override
  String importFailed(String error) {
    return 'Importeren mislukt: $error';
  }

  @override
  String get yesAddThem => 'Ja, toevoegen';

  @override
  String get nutritionDisplay => 'Voedingsweergave';

  @override
  String get nutritionDisplaySubtitle => 'Grafiekstijl, zichtbare voedingsstoffen';

  @override
  String get storeIntegrations => 'Wintelintegraties';

  @override
  String get instacart => 'Instacart';

  @override
  String get kroger => 'Kroger';

  @override
  String get connected => 'Verbonden';

  @override
  String get setCustomApiKey => 'Aangepaste API-sleutel instellen';

  @override
  String get useOwnInstacartKey => 'Je eigen Instacart Connect-sleutel gebruiken';

  @override
  String get instacartApiKey => 'Instacart API-sleutel';

  @override
  String get resetToDefaultKey => 'Herstellen naar standaardsleutel';

  @override
  String get removeCustomKey => 'Aangepaste sleutel verwijderen';

  @override
  String get signInToKroger => 'Inloggen bij Kroger';

  @override
  String get connectToAddItems => 'Verbind om items aan je winkelwagen toe te voegen';

  @override
  String get setPreferredStore => 'Voorkeurwinkel instellen';

  @override
  String get searchByZipCode => 'Zoeken op postcode';

  @override
  String get disconnect => 'Verbinding verbreken';

  @override
  String get apiKeySaved => 'API-sleutel opgeslagen';

  @override
  String get findYourKrogerStore => 'Je Kroger-winkel vinden';

  @override
  String get enterZipCode => 'Postcode invoeren';

  @override
  String storeSet(String name) {
    return 'Winkel ingesteld: $name';
  }

  @override
  String get menuImportSubtitle => 'Instagram, TikTok, websites...';

  @override
  String get menuSyncToMobile => 'Synchroniseren naar mobiel';

  @override
  String get menuSyncToDesktop => 'Synchroniseren naar desktop';

  @override
  String get menuTransferToPhone => 'Gegevens overzetten naar je telefoon';

  @override
  String get menuTransferToDevice => 'Gegevens overzetten naar ander apparaat';

  @override
  String get menuProfile => 'Profiel';

  @override
  String get menuProfileSubtitle => 'Je statistieken en voortgang bekijken';

  @override
  String get menuAchievementsSubtitle => 'Beloningen ontgrendelen';

  @override
  String get menuCosmetics => 'Cosmetica';

  @override
  String get menuCosmeticsSubtitle => 'Je uiterlijk aanpassen';

  @override
  String get menuLeaderboardsSubtitle => 'Concurreren met anderen';

  @override
  String get menuBossBattles => 'Bosggevechten';

  @override
  String get menuBossBattlesSubtitle => 'Epische kookuitdagingen';

  @override
  String get menuImportRecipes => 'Recepten importeren';

  @override
  String get menuHelpSupport => 'Help & Ondersteuning';

  @override
  String menuAppVersion(String version) {
    return 'Recipe Spellbook v$version';
  }

  @override
  String get menuShareApp => 'Recipe Spellbook delen';

  @override
  String get menuShareSubtitle => 'Nodig vrienden en familie uit om samen te koken!';

  @override
  String get menuShareMessage => 'Bekijk Recipe Spellbook - de beste recepten-app! https://recipespellbook.app/get';

  @override
  String get signIn => 'Inloggen';

  @override
  String get helpFromWebsite => 'Van een website';

  @override
  String get helpFromWebsiteDesc => 'Tik op + in een kookboek en plak een recept-URL.';

  @override
  String get helpFromSocial => 'Van Instagram of TikTok';

  @override
  String get helpFromSocialDesc => 'Kopieer de link van een receptpost, tik op + en plak.';

  @override
  String get helpFromPhoto => 'Van een foto';

  @override
  String get helpFromPhotoDesc => 'Maak een foto van een recept in een boek. Tik op + en kies Afbeelding.';

  @override
  String get helpFromPdf => 'Van een PDF';

  @override
  String get helpFromPdfDesc => 'Tik op + en kies Bestand om een PDF te importeren.';

  @override
  String get helpFromText => 'Van tekst';

  @override
  String get helpFromTextDesc => 'Kopieer recepttekst, tik op + en dan Plakken.';

  @override
  String get helpFromPaprika => 'Van Paprika';

  @override
  String get helpFromPaprikaDesc => 'Ga in Paprika naar Exporteren en kies HTML-formaat.';

  @override
  String get helpFromOtherApps => 'Van andere apps';

  @override
  String get helpFromOtherAppsDesc => 'De meeste recepten-apps kunnen exporteren als HTML of tekst.';

  @override
  String get helpCloudSync => 'Cloudsynchronisatie';

  @override
  String get helpCloudSyncDesc => 'Abonneer je op Cloud Sync om recepten te synchroniseren op al je apparaten.';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountSubscription => 'Abonnement';

  @override
  String get accountManageSubscription => 'Abonnement beheren';

  @override
  String get accountCloudSync => 'Cloudsynchronisatie';

  @override
  String get accountSyncNow => 'Nu synchroniseren';

  @override
  String get accountIntegrations => 'Integraties';

  @override
  String get accountDangerZone => 'Gevarenzone';

  @override
  String get purchasesRestored => 'Aankopen succesvol hersteld!';

  @override
  String get noPurchasesFound => 'Geen eerdere aankopen gevonden.';

  @override
  String get restoreFailed => 'Herstel mislukt. Probeer het opnieuw.';

  @override
  String get restorePurchasesLong => 'Aankopen herstellen';

  @override
  String get cancelled => 'Geannuleerd';

  @override
  String get accessUntil => 'toegang tot';

  @override
  String get renews => 'Verlenging';

  @override
  String get plan => 'Plan';

  @override
  String get upgradeDescription => 'Ontgrendel cloudsynchronisatie, slim importeren en meer.';

  @override
  String get syncDescription => 'Houd je recepten gesynchroniseerd tussen apparaten.';

  @override
  String get sync => 'Synchroniseren';

  @override
  String get signInToSync => 'Inloggen om te synchroniseren';

  @override
  String get signInSyncDesc => 'Maak back-up van je recepten, synchroniseer op meerdere apparaten en ontgrendel premium functies.';

  @override
  String get continueWithGoogle => 'Doorgaan met Google';

  @override
  String get continueWithApple => 'Doorgaan met Apple';

  @override
  String get signOut => 'Uitloggen';

  @override
  String get signOutQuestion => 'Uitloggen?';

  @override
  String get signOutDesc => 'Je recepten blijven op dit apparaat.';

  @override
  String get deleteAccount => 'Account verwijderen';

  @override
  String get deleteAccountQuestion => 'Account verwijderen?';

  @override
  String get deleteAccountDesc => 'Dit verwijdert je account en alle gesynchroniseerde gegevens permanent.\n\nLokaal opgeslagen recepten worden NIET verwijderd.';

  @override
  String get deletePermanently => 'Permanent verwijderen';

  @override
  String get deleteAccountFailed => 'Account verwijderen mislukt.';

  @override
  String get signInToApp => 'Inloggen bij Recipe Spellbook';

  @override
  String get signInSyncLong => 'Synchroniseer je recepten, ontgrendel cloud-back-up en toegang tot Pro-functies.';

  @override
  String get recipesStayOnDevice => 'Je recepten blijven op dit apparaat, ook zonder account.';

  @override
  String get upgradeToPro => 'Upgraden naar Pro';

  @override
  String subscriptionDot(String tier) {
    return 'Abonnement · $tier';
  }

  @override
  String get affluentLabsPro => 'Affluent Labs Pro';

  @override
  String cancelledAccessUntil(String date) {
    return 'Geannuleerd — toegang tot $date';
  }

  @override
  String get lifetimeNeverExpires => 'Levenslang — verloopt nooit';

  @override
  String renewsDate(String date) {
    return 'Verlengt op $date';
  }

  @override
  String get manageSubscription => 'Abonnement beheren';

  @override
  String get tierPremium => 'Premium';

  @override
  String get tierStandard => 'Standaard';

  @override
  String get tierBasic => 'Basis';

  @override
  String get tierFree => 'Gratis';

  @override
  String tierPlan(String tier) {
    return 'Plan $tier';
  }

  @override
  String get upgradeArrow => 'Upgraden →';

  @override
  String get syncNow => 'Nu synchroniseren';

  @override
  String get syncing => 'Synchroniseren...';

  @override
  String lastSynced(String time) {
    return 'Laatste sync $time';
  }

  @override
  String get notYetSynced => 'Nog niet gesynchroniseerd';

  @override
  String get cloudSyncSection => 'CLOUD SYNC';

  @override
  String get noRecipesPlannedThisWeek => 'Geen recepten gepland deze week';

  @override
  String get todayBadge => 'VANDAAG';

  @override
  String get noCourseAssigned => 'Geen gang';

  @override
  String get uncategorized => 'Ongecategoriseerd';

  @override
  String get allRecipesHaveCourse => 'Alle recepten hebben een gang!';

  @override
  String get allRecipesCategorized => 'Alle recepten zijn gecategoriseerd!';

  @override
  String get greatJobOrganizing => 'Goed georganiseerd!';

  @override
  String countOfTotal(int count, int total) {
    return '$count van $total';
  }

  @override
  String get tapToAssignCourse => 'Tik om gang toe te wijzen';

  @override
  String get tapToAssignCategory => 'Tik om categorie toe te wijzen';

  @override
  String deleteCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recepten',
      one: 'recept',
    );
    return '$count $_temp0 verwijderen?';
  }

  @override
  String countRecipesMovedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recepten',
      one: 'recept',
    );
    return '$count $_temp0 naar prullenbak verplaatst';
  }

  @override
  String get setCourse => 'Gang instellen';

  @override
  String get setCategory => 'Categorie instellen';

  @override
  String courseSetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recepten',
      one: 'recept',
    );
    return 'Gang ingesteld voor $count $_temp0';
  }

  @override
  String categorySetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recepten',
      one: 'recept',
    );
    return 'Categorie ingesteld voor $count $_temp0';
  }

  @override
  String countRecipesFavorited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recepten',
      one: 'recept',
    );
    return '$count $_temp0 toegevoegd aan favorieten';
  }

  @override
  String get bulkCourse => 'Gang';

  @override
  String get bulkCategory => 'Categorie';

  @override
  String get bulkFavorite => 'Favoriet';

  @override
  String get aiImportTitle => 'Importeren via AI';

  @override
  String get aiCopyPrompt => 'Prompt kopiëren';

  @override
  String get aiCopyPromptSubtitle => 'Plak dit in ChatGPT, Claude, Gemini of een AI naar keuze met je recept.';

  @override
  String get aiCopied => 'Gekopieerd!';

  @override
  String get aiCopyToClipboard => 'Prompt kopiëren';

  @override
  String get aiPreviewPrompt => 'Prompt bekijken';

  @override
  String get aiPasteOutput => 'AI-uitvoer plakken';

  @override
  String get aiPasteSubtitle => 'Plak de JSON van de AI of importeer een .json-bestand.';

  @override
  String get aiPasteFirst => 'Plak of laad eerst de JSON.';

  @override
  String aiFailedReadFile(String error) {
    return 'Fout bij lezen bestand: $error';
  }

  @override
  String get aiUntitledRecipe => 'Recept zonder titel';

  @override
  String get aiImporting => 'Importeren...';

  @override
  String get aiImportToCookbook => 'Importeren naar kookboek';

  @override
  String get aiImportSuccess => 'Recept succesvol geïmporteerd!';

  @override
  String get aiPreviewImport => 'Bekijken en importeren';

  @override
  String get aiPromptCopied => 'Prompt gekopieerd! Plak het in een AI met je recept.';

  @override
  String get aiLoadJsonFile => '.json-bestand laden';

  @override
  String get aiPaste => 'Plakken';

  @override
  String get aiTipsTitle => 'Tips';

  @override
  String get aiTip1 => 'Werkt met ChatGPT, Claude, Gemini, Copilot of elke AI';

  @override
  String get aiTip2 => 'Je kunt ook een foto van een recept maken en met de prompt plakken';

  @override
  String get aiTip3 => 'AI zet handgeschreven, gedrukte of webrecepten om';

  @override
  String get aiTip4 => 'Als de JSON fouten bevat, vraag de AI dit te corrigeren';

  @override
  String aiServingsLabel(String count) {
    return '$count porties';
  }

  @override
  String aiPrepLabel(String minutes) {
    return '${minutes}min prep';
  }

  @override
  String aiCookLabel(String minutes) {
    return '${minutes}min koken';
  }

  @override
  String aiIngredientsCount(int count) {
    return 'Ingrediënten ($count)';
  }

  @override
  String aiStepsCount(int count) {
    return 'Stappen ($count)';
  }

  @override
  String get restoreAllWarnings => 'Alle waarschuwingen herstellen';

  @override
  String get warningsRestoredForRecipe => 'Waarschuwingen hersteld voor dit recept';

  @override
  String get restoreAllWarningsQuestion => 'Alle waarschuwingen herstellen?';

  @override
  String get restoreAll => 'Alles herstellen';

  @override
  String get allWarningsRestored => 'Alle waarschuwingen hersteld';

  @override
  String dismissedWarnings(int count) {
    return '$count genegeerd';
  }

  @override
  String get restoringPurchases => 'Aankopen herstellen...';

  @override
  String get restorePurchases => 'Herstellen';

  @override
  String get compareAllPlans => 'Alle plannen vergelijken';

  @override
  String get oneTimeTab => 'Eenmalig';

  @override
  String get subscriptionTab => 'Abonnement';

  @override
  String get payOnceKeepForever => 'Eén keer betalen, voor altijd behouden';

  @override
  String get cloudSyncFreeTrial => 'Try free for 1 week';

  @override
  String get subscribeCloudSyncMonthlyTrialCta => 'Start free trial — then \$2.99/mo';

  @override
  String get subscribeCloudSyncYearlyTrialCta => 'Start free trial — then \$29.99/yr';

  @override
  String get cloudSyncFeature => 'Cloud Sync';

  @override
  String get cloudSyncFamilyFeature => 'Cloud Sync+';

  @override
  String get unableToLoadProducts => 'Kan producten niet laden.';

  @override
  String get noOfferingsAvailable => 'Geen aanbiedingen beschikbaar.';

  @override
  String purchaseFailed(String error) {
    return 'Aankoop mislukt: $error';
  }

  @override
  String get hintProductExample => 'bijv. Biologische tomatensaus';

  @override
  String get previewPhoto => 'Foto bekijken';

  @override
  String get retake => 'Opnieuw maken';

  @override
  String get usePhoto => 'Foto gebruiken';

  @override
  String get takePhoto => 'Foto maken';

  @override
  String get chooseFromGallery => 'Kiezen uit galerij';

  @override
  String get removeImage => 'Afbeelding verwijderen';

  @override
  String get tipsPlaceholder => 'Tips, variaties, bewaarinstructies...';

  @override
  String get totalCalories => 'Totaal calorieën';

  @override
  String get caloriesPerServing => 'Cal./portie';

  @override
  String get totalNutrition => 'Totaal';

  @override
  String get linkRecipe => 'Recept koppelen';

  @override
  String get addIngredient => 'Ingrediënt toevoegen';

  @override
  String get searchRecipesToLink => 'Recepten zoeken om te koppelen...';

  @override
  String linkToIngredient(String name) {
    return 'Koppelen aan \"$name\"';
  }

  @override
  String errorSavingRecipe(String error) {
    return 'Fout bij opslaan: $error';
  }

  @override
  String deleteSelectedCount(int count) {
    return '$count verwijderen';
  }

  @override
  String get takeAPhoto => 'Een foto maken';

  @override
  String get defaultLabel => 'Standaard';

  @override
  String get scaleRecipe => 'Recept schalen';

  @override
  String get scaleHint => 'bijv. 2,5';

  @override
  String get badgePinned => 'Vastgezet';

  @override
  String get badgeRecentlyViewed => 'Recent bekeken';

  @override
  String get displayOptions => 'Weergaveopties';

  @override
  String get showMealPlan => 'Maaltijdplan weergeven';

  @override
  String get showMealPlanSubtitle => 'Geplande recepten voor vandaag weergeven';

  @override
  String get showPinnedRecipes => 'Vastgezette recepten weergeven';

  @override
  String get showPinnedSubtitle => 'Vastgezette recepten weergeven';

  @override
  String get showRecentHistory => 'Recente geschiedenis weergeven';

  @override
  String get showRecentSubtitle => 'Recent bekeken recepten weergeven';

  @override
  String versionLabel(String version) {
    return 'Versie $version';
  }

  @override
  String get measurementsUS => 'kopjes, lepels, ons, °F';

  @override
  String get measurementsMetric => 'milliliters, gram, °C';

  @override
  String defaultRecipesImported(int count) {
    return '$count standaardrecepten geïmporteerd!';
  }

  @override
  String get shoppingListGeneratorTitle => 'Boodschappenlijstgenerator';

  @override
  String get exitShoppingListGeneratorQuestion => 'Generator verlaten?';

  @override
  String reviewAndAddItems(int count) {
    return 'Bekijken en toevoegen ($count items)';
  }

  @override
  String addedTotalItemsToList(int count) {
    return '$count items toegevoegd aan lijst';
  }

  @override
  String scaleMultiplier(String scale) {
    return '${scale}x';
  }

  @override
  String get printIngredients => 'Ingrediënten';

  @override
  String get printInstructions => 'Instructies';

  @override
  String get printNotes => 'Notities';

  @override
  String printPrep(int minutes) {
    return 'Prep: $minutes min';
  }

  @override
  String printCook(int minutes) {
    return 'Kooktijd: $minutes min';
  }

  @override
  String get printFooter => 'Afgedrukt vanuit Recipe Spellbook';

  @override
  String printPage(int current, int total) {
    return 'Pagina $current van $total';
  }

  @override
  String get menuNavigation => 'NAVIGATIE';

  @override
  String get menuImport => 'IMPORTEREN';

  @override
  String get menuKitchenBuddyMode => 'RPG-MODUS';

  @override
  String get menuSocial => 'SOCIAAL';

  @override
  String get menuApp => 'APP';

  @override
  String get historyCount => 'Geschiedenisaantal';

  @override
  String get historyCountSubtitle => 'Maximum aantal recente recepten om weer te geven';

  @override
  String get restoreAllWarningsDesc => 'Dit heractiveer allergiewaarschuwingen voor alle recepten.';

  @override
  String get signInToContinue => 'Inloggen om door te gaan';

  @override
  String get signInForPurchaseDesc => 'Een account is vereist voor aankoop.';

  @override
  String get menuAchievements => 'Prestaties';

  @override
  String get menuLeaderboards => 'Ranglijsten';

  @override
  String get requiresPremium => 'Premium vereist';

  @override
  String deleteCount(int count) {
    return '$count verwijderen';
  }

  @override
  String get tapToSelectPhoto => 'Tik om te selecteren uit galerij of camera';

  @override
  String get rating => 'Beoordeling';

  @override
  String get usUnits => 'cups, tablespoons, ounces, °F';

  @override
  String get metricUnits => 'milliliters, grams, °C';

  @override
  String selectedCount(int count) {
    return '$count geselecteerd';
  }

  @override
  String deleteRecipesConfirm(int count) {
    return '$count recept(en) verwijderen?';
  }

  @override
  String courseSetForRecipes(int count) {
    return 'Gang ingesteld voor $count recept(en)';
  }

  @override
  String get recipeImportedSuccess => 'Recept succesvol geïmporteerd!';

  @override
  String get promptCopied => 'Prompt gekopieerd! Plak het in een AI met je recept.';

  @override
  String get importFromAI => 'Importeren via AI';

  @override
  String get paste => 'Plakken';

  @override
  String get previewAndImport => 'Bekijken en importeren';

  @override
  String get signInDescription => 'Sla je recepten op, synchroniseer op meerdere apparaten.';

  @override
  String get signOutConfirmTitle => 'Uitloggen?';

  @override
  String get signOutConfirmMessage => 'Je recepten blijven op dit apparaat.';

  @override
  String get deleteAccountConfirmTitle => 'Account verwijderen?';

  @override
  String get deleteAccountConfirmMessage => 'Dit verwijdert je account permanent.\n\nLokale recepten worden NIET verwijderd.';

  @override
  String planLabel(String label) {
    return 'Plan $label';
  }

  @override
  String permanentlyDeleteWarning(String scope) {
    return 'Dit verwijdert $scope permanent. Deze actie kan niet ongedaan worden gemaakt.';
  }

  @override
  String recipesMovedToTrash(int count) {
    return '$count recept(en) naar prullenbak verplaatst';
  }

  @override
  String recipesFavorited(int count) {
    return '$count recept(en) toegevoegd aan favorieten';
  }

  @override
  String get upgradeRecipeSpellbook => 'Recipe Spellbook upgraden';

  @override
  String get choosePlanSubtitle => 'Kies het juiste plan voor jouw keuken';

  @override
  String get premiumInfoNotice => 'Premium is een eenmalige aankoop die je gratis ervaring verbetert.';

  @override
  String get bestValue => 'BESTE WAARDE';

  @override
  String get billedMonthly => 'Maandelijks gefactureerd';

  @override
  String get save16Yearly => 'Bespaar 16% — slechts €2,50/maand';

  @override
  String get save16Badge => 'BESPAAR 16%';

  @override
  String get save17Yearly => 'Bespaar 17% — slechts €4,17/maand';

  @override
  String get subscriptionsIncludePremium => 'Alle abonnementen bevatten alles uit Premium.';

  @override
  String get monthly => 'Maandelijks';

  @override
  String get yearly => 'Jaarlijks';

  @override
  String get purchasePremiumCta => 'Premium kopen — €6,99';

  @override
  String get subscribeCloudSyncMonthlyCta => 'Abonneren — €2,99/maand';

  @override
  String get subscribeCloudSyncYearlyCta => 'Abonneren — €29,99/jaar';

  @override
  String get subscribeCloudSyncPlusMonthlyCta => 'Abonneren — €4,99/maand';

  @override
  String get subscribeCloudSyncPlusYearlyCta => 'Abonneren — €49,99/jaar';

  @override
  String get signInRequiredBeforePurchase => 'Inloggen vereist voor aankoop';

  @override
  String get terms => 'Voorwaarden';

  @override
  String get privacy => 'Privacy';

  @override
  String get comparePlans => 'Plannen vergelijken';

  @override
  String get featureCloudSyncPersonal => 'Cloud sync (persoonlijk)';

  @override
  String get featurePhotosOnSteps => 'Foto\'s bij stappen';

  @override
  String get featureCloudStorageLimited => 'Cloud storage — Limited';

  @override
  String get featureFamilySharing5 => 'Gezinsdeling (5 leden)';

  @override
  String get featureCloudStorage => 'Cloud storage';

  @override
  String get featureSharedLists => 'Gedeelde boodschappenlijsten';

  @override
  String get featureSharedCookbooks => 'Gedeelde kookboeken';

  @override
  String get featureSharedMealPlan => 'Gedeeld maaltijdplan';

  @override
  String get featureAutoBackups => 'Automatic backups';

  @override
  String get featureFamilySharing10 => 'Gezinsdeling (10 leden)';

  @override
  String get featurePrioritySync => 'Prioriteitssynchronisatie';

  @override
  String get featureFutureAdvanced => 'Toekomstige geavanceerde functies inbegrepen';

  @override
  String get tierCloudSync => 'Cloud\nSync';

  @override
  String get tierCloudSyncPlus => 'Cloud\nSync+';

  @override
  String get comparePrice => 'Prijs';

  @override
  String get priceFree => '€0';

  @override
  String get pricePremium => '€6,99\neenmalig';

  @override
  String get priceCloudSync => '€2,99\n/maand';

  @override
  String get priceCloudSyncPlus => '€4,99\n/maand';

  @override
  String get compareDeviceTransfer => 'Apparaatoverdracht';

  @override
  String get qrCode => 'QR-code';

  @override
  String get cloud => 'Cloud';

  @override
  String get comparePhotoStorage => 'Fotoopslag';

  @override
  String get compareStepPhotos => 'Stap-foto\'s';

  @override
  String get compareFamilySharing => 'Gezinsdeling';

  @override
  String get compareSharedLists => 'Gedeelde lijsten';

  @override
  String get compareSharedCookbooks => 'Gedeelde kookboeken';

  @override
  String get compareSharedMealPlan => 'Gedeeld maaltijdplan';

  @override
  String get compareBackups => 'Back-ups';

  @override
  String get compareCloudStorage => 'Cloudopslag';

  @override
  String get compareCloudStorageBasic => 'Basis';

  @override
  String get compareCloudStorageStandard => 'Standaard';

  @override
  String get compareCloudStorageExtended => 'Uitgebreid';

  @override
  String get printOf => 'van';

  @override
  String get printRecipe => 'Afdrukken';

  @override
  String get stackedLayout => 'Gestapelde indeling';

  @override
  String get tabbedLayout => 'Tabbladindeling';

  @override
  String get printLabelIngredients => 'Ingrediënten';

  @override
  String get printLabelInstructions => 'Instructies';

  @override
  String get printLabelNotes => 'Notities';

  @override
  String get printLabelPrep => 'Prep';

  @override
  String get printLabelCook => 'Kooktijd';

  @override
  String get printLabelFooter => 'Afgedrukt vanuit Recipe Spellbook';

  @override
  String get printLabelPage => 'Pagina';

  @override
  String get printLabelOf => 'van';

  @override
  String get smallerText => 'Kleinere tekst';

  @override
  String get largerText => 'Grotere tekst';

  @override
  String get textSize => 'Tekstgrootte';

  @override
  String get ingredientPreview => 'Ingrediëntenvoorbeeld';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get learnMore => 'Meer informatie';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get upgrade => 'Upgraden';

  @override
  String get cookingMode => 'Kookmodus';

  @override
  String get mealTypeDessert => 'Dessert';

  @override
  String get noContentToSave => 'Geen inhoud om op te slaan';

  @override
  String get recipeSaved => 'Recept opgeslagen!';

  @override
  String get qrScanningMobileOnly => 'QR-scannen is alleen beschikbaar op mobiel.';

  @override
  String get communityComingSoon => 'Communityfuncties komen binnenkort!';

  @override
  String somethingWentWrong(String error) {
    return 'Er is iets misgegaan: $error';
  }

  @override
  String starterRecipesAdded(int count) {
    return '$count startersrecepten toegevoegd! 🎉';
  }

  @override
  String get enterAtLeastOneNutrient => 'Voer minimaal calorieën of een macronutriënt in';

  @override
  String addedToMealPlan(String mealType, String date) {
    return 'Toegevoegd aan $mealType op $date';
  }

  @override
  String get noItemsFoundInText => 'Geen items gevonden in tekst';

  @override
  String get noTextFoundInImage => 'Geen tekst gevonden in afbeelding';

  @override
  String get addDayToShoppingList => 'Dag toevoegen aan lijst';

  @override
  String get sendDayToShoppingList => 'Dag sturen naar lijst';

  @override
  String get removeMeal => 'Maaltijd verwijderen';

  @override
  String removeMealConfirm(String recipeName) {
    return '$recipeName verwijderen van deze dag?';
  }

  @override
  String get actionRemove => 'Verwijderen';

  @override
  String get plannerMealRemoved => 'Maaltijd verwijderd';

  @override
  String get weekStartsOn => 'Week begint op';

  @override
  String get monday => 'Maandag';

  @override
  String get saturday => 'Zaterdag';

  @override
  String get sunday => 'Zondag';

  @override
  String get ingredientHeader => 'Koptekst';

  @override
  String get ingredientHeaderHint => 'bijv. Voor de saus';

  @override
  String get settingsWeekStartDay => 'Week begint op';

  @override
  String get settingsSurpriseMe => '\'Verras me\'-kaart tonen';

  @override
  String get settingsSurpriseMeSubtitle => 'Receptsuggestiekaart op het startscherm tonen';

  @override
  String get settingsNotifications => 'Meldingen';

  @override
  String get settingsNotifCooking => 'Kookherinneringen';

  @override
  String get settingsNotifCookingSubtitle => 'Maaltijdplan-meldingen en kookherinneringen';

  @override
  String get settingsNotifCommunity => 'Community-updates';

  @override
  String get settingsNotifCommunitySubtitle => 'Downloads, beoordelingen en reacties op je recepten';

  @override
  String get settingsNotifAchievements => 'Prestaties';

  @override
  String get settingsNotifAchievementsSubtitle => 'Ontgrendelde prestaties en mijlpaalmeldingen';

  @override
  String get settingsNotifBuddy => 'Questherinneringen';

  @override
  String get settingsNotifBuddySubtitle => 'Dagelijkse quest-resets en XP-herinneringen';

  @override
  String get settingsNotifManagePreferences => 'Meldingsvoorkeuren beheren';

  @override
  String get settingsNotifNewDownloads => 'Nieuwe downloads';

  @override
  String get settingsNotifNewDownloadsSubtitle => 'Wanneer iemand je gepubliceerde recept downloadt';

  @override
  String get settingsNotifRatingUpdates => 'Beoordelingsupdates';

  @override
  String get settingsNotifRatingUpdatesSubtitle => 'Wanneer je gepubliceerde recept een nieuwe beoordeling krijgt';

  @override
  String get settingsNotifComments => 'Reacties';

  @override
  String get settingsNotifCommentsSubtitle => 'Wanneer iemand een reactie plaatst op je recept';

  @override
  String get settingsNotifSyncNote => 'Meldingsvoorkeuren worden gesynchroniseerd met je account.';

  @override
  String get tuesday => 'Dinsdag';

  @override
  String get wednesday => 'Woensdag';

  @override
  String get thursday => 'Donderdag';

  @override
  String get friday => 'Vrijdag';

  @override
  String shoppingAddedToList(int count, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'items',
      one: 'item',
    );
    return '$count $_temp0 toegevoegd aan \"$listName\"';
  }

  @override
  String shoppingAddedAndCombined(int added, int combined, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: 'items',
      one: 'item',
    );
    return '$added $_temp0 toegevoegd aan \"$listName\", $combined gecombineerd';
  }

  @override
  String shoppingItemsUpdated(int count, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'items',
      one: 'item',
    );
    return '$count $_temp0 bijgewerkt in \"$listName\"';
  }

  @override
  String shoppingAddError(String message) {
    return 'Fout: $message';
  }

  @override
  String get editCookbook => 'Kookboek bewerken';

  @override
  String get newCookbook => 'Nieuw kookboek';

  @override
  String get tapToAddCoverImage => 'Tik om omslagafbeelding toe te voegen';

  @override
  String get cookbookDescriptionLabel => 'Beschrijving';

  @override
  String get cookbookDescriptionHint => 'Een verzameling recepten...';

  @override
  String get cookbookNameRequired => 'Voer een naam in';

  @override
  String get addCover => 'Omslag toevoegen';

  @override
  String recipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recepten',
      one: 'recept',
    );
    return '$count $_temp0';
  }

  @override
  String cookbookDeleteWithRecipes(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recepten',
      one: 'recept',
    );
    return 'Dit kookboek bevat $count $_temp0. Ze worden naar de prullenbak verplaatst.\n\nWeet je zeker dat je \"$name\" wilt verwijderen?';
  }

  @override
  String cookbookDeleteConfirmNamed(String name) {
    return 'Weet je zeker dat je \"$name\" wilt verwijderen?';
  }

  @override
  String get shareCookbook => 'Kookboek delen';

  @override
  String get cookbookEmpty => 'Dit kookboek heeft geen recepten om te delen';

  @override
  String get recipes => 'recepten';

  @override
  String get sendSuggestion => 'Suggestie sturen';

  @override
  String get sendSuggestionSubtitle => 'Help ons Recipe Spellbook te verbeteren';

  @override
  String get reportBug => 'Bug rapporteren';

  @override
  String get reportBugSubtitle => 'Werkt iets niet goed?';

  @override
  String get joinDiscord => 'Ons Discord-server joinen';

  @override
  String get joinDiscordSubtitle => 'Krijg hulp en deel recepten';

  @override
  String get actionSend => 'Sturen';

  @override
  String get suggestionDescription => 'We zijn dol op je ideeën! Je suggestie wordt rechtstreeks naar ons team gestuurd.';

  @override
  String get suggestionTitleLabel => 'Suggestietitel';

  @override
  String get suggestionTitleHint => 'bijv. Donkere modus voor koken toevoegen';

  @override
  String get suggestionDetailsLabel => 'Details';

  @override
  String get suggestionDetailsHint => 'Beschrijf je idee in detail...';

  @override
  String get contactOptionalLabel => 'Contact (optioneel)';

  @override
  String get contactOptionalHint => 'E-mail of Discord-naam';

  @override
  String get suggestionSent => 'Bedankt! Je suggestie is verstuurd 💡';

  @override
  String get bugDescription => 'Bug gevonden? Vertel het ons en we lossen het op.';

  @override
  String get bugTitleLabel => 'Bugtitel';

  @override
  String get bugTitleHint => 'bijv. App crasht bij PDF importeren';

  @override
  String get bugDetailsLabel => 'Wat is er gebeurd?';

  @override
  String get bugDetailsHint => 'Beschrijf wat er misging...';

  @override
  String get bugStepsLabel => 'Stappen om te reproduceren (optioneel)';

  @override
  String get bugStepsHint => '1. Recept openen\n2. Op delen tikken\n3. App crasht';

  @override
  String get bugReportSent => 'Bedankt! Je bugrapport is verstuurd 🐛';

  @override
  String get feedbackFieldsRequired => 'Vul de titel en details in';

  @override
  String get feedbackSendError => 'Kan feedback niet versturen. Controleer je verbinding.';

  @override
  String get mealTypeAppetizer => 'Voorgerecht';

  @override
  String get allergenContains => 'Contains';

  @override
  String get settingsIngredientLayout => 'Ingrediëntenindeling';

  @override
  String get ingredientLayoutInline => 'Inline — 1 tl boter';

  @override
  String get ingredientLayoutColumnar => 'Kolommen — hoeveelheden uitgelijnd';

  @override
  String get settingsIngredientLayoutDescription => 'Kies hoe hoeveelheden en ingrediëntnamen worden weergegeven.';

  @override
  String get ingredientLayoutInlineDescription => 'Hoeveelheid, eenheid en naam in natuurlijke volgorde';

  @override
  String get ingredientLayoutColumnarDescription => 'Hoeveelheden uitgelijnd in vaste kolom';

  @override
  String get ingredientLayoutInfoText => 'Deze instelling geldt voor de receptweergave, lijstgenerator en afgedrukte recepten.';

  @override
  String get searchCookbooks => 'Kookboeken zoeken...';

  @override
  String get aboutWebsite => 'Website';

  @override
  String get aboutPrivacyPolicy => 'Privacybeleid';

  @override
  String get aboutPrivacyPolicySub => 'Hoe we je gegevens behandelen';

  @override
  String get aboutTermsOfService => 'Servicevoorwaarden';

  @override
  String get aboutTermsOfServiceSub => 'Gebruiksvoorwaarden';

  @override
  String get aboutCommunity => 'Community';

  @override
  String get aboutCommunitySub => 'Ons Discord-server joinen';

  @override
  String get aboutReportBug => 'Bug rapporteren';

  @override
  String get aboutReportBugSub => 'Help ons de app te verbeteren';

  @override
  String get aboutRateApp => 'App beoordelen';

  @override
  String get aboutRateAppSub => 'Een recensie achterlaten in de store';

  @override
  String get aboutLicenses => 'Open-source licenties';

  @override
  String get aboutLicensesSub => 'Gebruikte software van derden';

  @override
  String get sortOrder => 'Sorteervolgorde';

  @override
  String get ingredientAddHeader => 'Koptekst toevoegen';

  @override
  String get saveAsRecipe => 'Opslaan als recept';

  @override
  String get exportFullBackup => 'Volledige back-up';

  @override
  String get exportCookbooksRecipes => 'Kookboeken en recepten';

  @override
  String get exportShoppingLists => 'Boodschappenlijsten';

  @override
  String get exportMealPlans => 'Maaltijdplannen';

  @override
  String get exportTags => 'Labels';

  @override
  String get exportCategories => 'Aangepaste categorieën';

  @override
  String get exportCourses => 'Aangepaste gangen';

  @override
  String get createRecipeManually => 'Of maak een recept handmatig';

  @override
  String get transferYourRecipes => 'Je recepten overzetten';

  @override
  String get transferUpgradeBanner => 'Automatische synchronisatie gewenst? Upgrade naar Premium voor cloud-sync op al je apparaten.';

  @override
  String get transferCodeLength => 'Code moet 6 tekens zijn';

  @override
  String get transferItemRecipes => 'Alle recepten';

  @override
  String get transferItemCookbooks => 'Kookboeken & categorieën';

  @override
  String get transferItemMealPlans => 'Maaltijdplannen';

  @override
  String get transferItemShoppingLists => 'Boodschappenlijsten';

  @override
  String get transferItemSettings => 'App-instellingen';

  @override
  String get transferItemAccount => 'Accountaanmelding (als afzender is ingelogd)';

  @override
  String get codeCopied => 'Code gekopieerd!';

  @override
  String get transferTitle => 'Gegevens overzetten';

  @override
  String get transferReceiveSubtitle => 'Voer een code in of scan de QR van het verzendende apparaat';

  @override
  String get transferPreparing => 'Je gegevens worden voorbereid...';

  @override
  String get transferFailed => 'Overdracht mislukt';

  @override
  String get transferScanDesc => 'Scan deze QR op je andere apparaat, of voer de code hieronder in.';

  @override
  String get transferReady => 'Klaar voor overdracht';

  @override
  String get transferCodeExpires => 'Deze code verloopt over 15 minuten';

  @override
  String get transferComplete => 'Overdracht voltooid!';

  @override
  String get transferAccountSynced => 'Account ingelogd van afzender';

  @override
  String get transferScanQr => 'QR-code scannen';

  @override
  String get transferScanQrDesc => 'Richt je camera op de QR op het andere apparaat';

  @override
  String get transferEnterCode => 'Overdrachtscode invoeren';

  @override
  String get transferWhatMoves => 'Wat wordt overgezet:';

  @override
  String get transferMergeNote => 'Bestaande gegevens op dit apparaat worden samengevoegd. Duplicaten worden overgeslagen.';

  @override
  String get transferPointCamera => 'Richt op de QR-code van het verzendende apparaat';

  @override
  String get labelPrepMin => 'Prep (min)';

  @override
  String get labelCookMin => 'Koken (min)';

  @override
  String get labelTotalCal => 'Totaal cal';

  @override
  String get labelCalPerServing => 'Cal/portie';

  @override
  String get tooltipViewSize => 'Weergavegrootte';

  @override
  String get pantryClearTitle => 'Voorraadkast legen?';

  @override
  String get pantryAddHint => 'Item toevoegen aan voorraadkast...';

  @override
  String get pantryAddStaples => 'Alle basisproducten toevoegen';

  @override
  String get pantrySearchHint => 'Voorraadkast doorzoeken...';

  @override
  String get settingsRecipesShopping => 'Recepten & Boodschappen';

  @override
  String get settingsAdvanced => 'Geavanceerde instellingen';

  @override
  String get settingsAdvancedSubtitle => 'Labels, gangen, categorieën & meer';

  @override
  String get settingsRestoreDefaults => 'Restore Default Recipes';

  @override
  String get settingsRestoreDefaultsSubtitle => 'Re-add the 10 starter recipes';

  @override
  String get settingsRestoreDefaultsConfirm => 'Add 10 starter recipes to your cookbook? Existing recipes won\'t be affected.';

  @override
  String get settingsDeleteData => 'Gegevens verwijderen';

  @override
  String get settingsDeleteDataSubtitle => 'App- of cloudgegevens wissen';

  @override
  String get settingsUpgradeSubtitle => 'Cloud-sync, foto\'s & meer';

  @override
  String get settingsTextSizeSubtitle => 'Tekstgrootte in de hele app aanpassen';

  @override
  String get settingsGoogleOrApple => 'Google of Apple';

  @override
  String get alwaysVisible => 'Altijd zichtbaar';

  @override
  String get chartNumbers => 'Getallen';

  @override
  String get chartDonut => 'Donut';

  @override
  String get chartBars => 'Staafdiagram';

  @override
  String get unitKcal => 'kcal';

  @override
  String get nutritionCustomScale => 'Aangepaste schaal';

  @override
  String get nutritionScaleLabel => 'Schaalmultiplicator';

  @override
  String get nutritionScaleHint => 'bijv. 0,5, 1,5, 3,0';

  @override
  String get nutritionSet => 'Instellen';

  @override
  String get nutritionApplyRecalculate => 'Toepassen & Herberekenen';

  @override
  String get calAbbrev => 'Cal';

  @override
  String get nutritionServingSizeHint => 'bijv. 1 kopje, 100g';

  @override
  String get shoppingExportList => 'Lijst exporteren';

  @override
  String get shoppingExportListSubtitle => 'Delen als tekstbestand of back-up';

  @override
  String get shoppingImportList => 'Lijst importeren';

  @override
  String get shoppingImportListSubtitle => 'Items toevoegen vanuit bestand, foto of tekst';

  @override
  String get shoppingScanBarcodeSubtitle => 'Een product opzoeken om toe te voegen';

  @override
  String get exportBackupFile => 'Back-upbestand';

  @override
  String get exportBackupFileSubtitle => 'Voor overdracht naar een ander apparaat of app';

  @override
  String get exportFormattedList => 'Opgemaakte lijst';

  @override
  String get exportFormattedListSubtitle => 'Met selectievakjes — ideaal voor notitie-apps';

  @override
  String get exportPlainText => 'Platte tekst';

  @override
  String get exportPlainTextSubtitle => 'Eenvoudige lijst — overal plakken';

  @override
  String get importFromBackupFile => 'Van back-upbestand';

  @override
  String get importFromBackupSubtitle => 'Een Recipe Spellbook-back-up importeren';

  @override
  String get importFromTextShoppingSubtitle => 'Plak of typ een lijst met items';

  @override
  String get importFromPhotoOcrSubtitle => 'OCR-scan van een handgeschreven of gedrukte lijst';

  @override
  String get importFromPhotoGallerySubtitle => 'Maak een foto of kies uit galerij';

  @override
  String get shoppingSendToStore => 'Naar winkel sturen';

  @override
  String get shoppingSendToCart => 'Naar winkelwagen sturen';

  @override
  String get shoppingCopyToClipboard => 'Lijst kopiëren naar klembord';

  @override
  String get shoppingGoToCart => 'Naar winkelwagen';

  @override
  String get shoppingAddItems => 'Items toevoegen';

  @override
  String get shoppingAddItemHintLong => 'bijv. 2 kopjes bloem, kipfilet...';

  @override
  String get importReviewItems => 'Items bekijken';

  @override
  String get importNoItemsDetected => 'Geen items gedetecteerd';

  @override
  String get mealPlanDate => 'Datum';

  @override
  String get mealPlanThisWeekend => 'Dit weekend';

  @override
  String get menuKitchenBuddy => 'RPG-profiel';

  @override
  String get menuTools => 'Hulpmiddelen';

  @override
  String get menuSupport => 'Ondersteuning';

  @override
  String get menuHowCanWeHelp => 'Hoe kunnen we helpen?';

  @override
  String get menuGetInTouch => 'Neem contact op of bekijk onze gidsen.';

  @override
  String get menuVisitWebsite => 'Bezoek onze website';

  @override
  String get feedbackTitleLabel => 'Titel';

  @override
  String get feedbackDetailsLabel => 'Details';

  @override
  String get feedbackDescriptionLabel => 'Beschrijving';

  @override
  String get menuSigningIn => 'Bezig met inloggen…';

  @override
  String get menuSignInSync => 'Inloggen om te synchroniseren & back-uppen';

  @override
  String get tagsSave => 'Labels opslaan';

  @override
  String get recipeFieldCategories => 'Categorieën';

  @override
  String get selectCategories => 'Categorieën selecteren';

  @override
  String get searchOrCreateNew => 'Zoeken of nieuwe aanmaken...';

  @override
  String get noMatchesFound => 'Geen overeenkomsten gevonden';

  @override
  String get taxonomyAddCategoryNew => 'Toevoegen als nieuwe categorie';

  @override
  String get ingredientSubstitutionsTitle => 'Ingrediëntvervangers';

  @override
  String get ingredientSubstitutionsSearch => 'Zoek een ingrediënt...';

  @override
  String get ingredientSubstitutionsSearchAll => 'Alle vervangers doorzoeken';

  @override
  String get ingredientName => 'Ingrediëntnaam';

  @override
  String get ingredientNameHint => 'bijv. kurkuma, tahini, miso';

  @override
  String get ingredientBulkHint => 'Voer één ingrediënt per regel in:\n\n2 kopjes bloem\n1 tl zout\n3 eieren';

  @override
  String get viewPlans => 'Plannen bekijken';

  @override
  String get renewsLabel => 'Verlengt op';

  @override
  String get upgradeToProUnlock => 'Upgrade naar Pro om te ontgrendelen';

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
  String get settingsNoMatchingSettings => 'Geen overeenkomende instellingen';

  @override
  String get settingsSearchHint => 'Instellingen zoeken...';

  @override
  String get textSizeSmall => 'Klein';

  @override
  String get textSizeDefault => 'Standaard';

  @override
  String get textSizeMedium => 'Gemiddeld';

  @override
  String get textSizeLarge => 'Groot';

  @override
  String get textSizeExtraLarge => 'Extra groot';

  @override
  String get resetDataClearedDesc => 'Alle gegevens zijn succesvol gewist.\n\nWil je de 10 standaard startersrecepten importeren?';

  @override
  String get yesImport => 'Ja, importeren';

  @override
  String get importingDefaultRecipes => 'Standaardrecepten importeren...';

  @override
  String get checking => 'Controleren...';

  @override
  String get connectedTapToManage => 'Verbonden • Tik om te beheren';

  @override
  String get notConnected => 'Niet verbonden';

  @override
  String get tapToSignIn => 'Tik om in te loggen';

  @override
  String get noneSelected => 'Geen selectie';

  @override
  String get partialBackup => 'Gedeeltelijke back-up';

  @override
  String get settingsShopping => 'Boodschappen & Planning';

  @override
  String get settingsManage => 'Beheren';

  @override
  String get manageTags => 'Labels beheren';

  @override
  String tagsApplied(int count) {
    return '$count labels toegepast';
  }

  @override
  String tagsEditTitle(String name) {
    return '\"$name\" bewerken';
  }

  @override
  String get tagsEditComingSoon => 'Labels bewerken binnenkort beschikbaar!';

  @override
  String tagsRecipeCount(int count) {
    return '$count recepten';
  }

  @override
  String get communityMyPublications => 'Mijn publicaties';

  @override
  String get communitySearchCookbooks => 'Kookboeken zoeken...';

  @override
  String get communitySortRecent => 'Recent';

  @override
  String get communitySortPopular => 'Populair';

  @override
  String get communitySortMostDownloaded => 'Meest gedownload';

  @override
  String communityNoResultsFor(String query) {
    return 'Geen resultaten voor \"$query\"';
  }

  @override
  String get communityNoCookbooksYet => 'Nog geen kookboeken';

  @override
  String get communityClearSearch => 'Zoekopdracht wissen';

  @override
  String get communityPublish => 'Publiceren';

  @override
  String communityByPublisher(String name) {
    return 'door $name';
  }

  @override
  String communityRecipeCount(int count) {
    return '$count recepten';
  }

  @override
  String get communityPublishCookbook => 'Kookboek publiceren';

  @override
  String get communitySignInToPublish => 'Inloggen om te publiceren';

  @override
  String get communitySignInToPublishMessage => 'Je hebt een account nodig om kookboeken te delen met de community.';

  @override
  String get communityGoToSettings => 'Naar instellingen';

  @override
  String get communityNoCookbooksToPublish => 'Geen kookboeken om te publiceren';

  @override
  String get communityPublishInfo => 'Kookboeken moeten minimaal 10 recepten bevatten om te publiceren. Je recepten worden gedeeld als momentopname — wijzigingen worden niet gesynchroniseerd.';

  @override
  String get communitySelectCookbook => 'Selecteer een kookboek om te publiceren';

  @override
  String communityNeedMinRecipes(int count) {
    return 'Minimaal 10 recepten nodig (heeft $count)';
  }

  @override
  String get communityPublishConfirmTitle => 'Publiceren naar Community?';

  @override
  String communityPublishConfirmMessage(String name, int count) {
    return '\"$name\" ($count recepten) wordt openbaar gedeeld. Iedereen kan het bekijken en downloaden.\n\nJe kunt het op elk moment ongedaan maken.';
  }

  @override
  String communityPublishSuccess(String name) {
    return '\"$name\" gepubliceerd naar de community!';
  }

  @override
  String get communityPublishFailed => 'Publiceren mislukt';

  @override
  String communityRecipeCountNeedMore(int count) {
    return '$count recepten (10+ nodig)';
  }

  @override
  String get communityNoPublicationsYet => 'Nog geen publicaties';

  @override
  String get communityNoPublicationsMessage => 'Publiceer een kookboek om het te delen met de community.';

  @override
  String get communityUnpublish => 'Publicatie ongedaan maken';

  @override
  String get communityUnpublishConfirmTitle => 'Publicatie ongedaan maken?';

  @override
  String communityUnpublishConfirmMessage(String title) {
    return '\"$title\" verwijderen uit de community? Mensen die het al gedownload hebben behouden hun kopie.';
  }

  @override
  String communityUnpublishSuccess(String title) {
    return '\"$title\" publicatie ongedaan gemaakt';
  }

  @override
  String get communityUnpublishFailed => 'Publicatie ongedaan maken mislukt';

  @override
  String get communityRemovedByModeration => 'Verwijderd door moderatie';

  @override
  String communityPublicationStats(int recipeCount, int downloadCount, String timeAgo) {
    return '$recipeCount recepten · $downloadCount downloads · $timeAgo';
  }

  @override
  String get communityPublicationNotFound => 'Publicatie niet gevonden';

  @override
  String get communityReport => 'Rapporteren';

  @override
  String get communityReportTitle => 'Dit kookboek rapporteren';

  @override
  String get communityReportSpam => 'Spam of lage kwaliteit';

  @override
  String get communityReportInappropriate => 'Ongepaste inhoud';

  @override
  String get communityReportStolen => 'Gestolen / gekopieerde recepten';

  @override
  String get communityReportOther => 'Anders';

  @override
  String get communityReportSuccess => 'Melding ingediend. Bedankt!';

  @override
  String get communitySignInToReport => 'Inloggen om inhoud te rapporteren';

  @override
  String get communityDownloadFailed => 'Downloaden mislukt';

  @override
  String communityDownloadSuccess(String title, int count) {
    return '\"$title\" gedownload — $count recepten toegevoegd!';
  }

  @override
  String communityDownloadFailedError(String error) {
    return 'Downloaden mislukt: $error';
  }

  @override
  String communityDownloadCount(int count) {
    return '$count downloads';
  }

  @override
  String get communityDownloading => 'Downloaden...';

  @override
  String get communityDownloadToMyCookbooks => 'Downloaden naar Mijn kookboeken';

  @override
  String communityPrepTime(int minutes) {
    return '${minutes}m prep';
  }

  @override
  String communityCookTime(int minutes) {
    return '${minutes}m koken';
  }

  @override
  String communityServingsCount(int count) {
    return '$count porties';
  }

  @override
  String communityIngredientCount(int count) {
    return '$count ingrediënten';
  }

  @override
  String get deleteRecipesTrashMessage => 'Recepten worden naar de prullenbak verplaatst. Je kunt ze later herstellen.';

  @override
  String get hintTitleExample => 'bijv. Oma\'s appeltaart';

  @override
  String get hintDescription => 'Een korte beschrijving van het recept';

  @override
  String get hintServingsExample => 'bijv. 4';

  @override
  String get prepMin => 'Prep (min)';

  @override
  String get cookMin => 'Koken (min)';

  @override
  String get hintNotes => 'Tips, variaties, bewaarinstructies...';

  @override
  String get pinchToZoomCropped => 'Knijp om te zoomen · Bijgesneden gebied wordt opgeslagen';

  @override
  String get pinchToZoomOrUseAsIs => 'Knijp om te zoomen en bij te snijden · Of gebruik zoals het is';

  @override
  String get savingLabel => 'Opslaan...';

  @override
  String get emptyHeader => '(lege koptekst)';

  @override
  String get emptyIngredient => '(leeg ingrediënt)';

  @override
  String get recipeUpdated => 'Recept bijgewerkt!';

  @override
  String get nutritionLessInfo => 'Minder info';

  @override
  String get nutritionMoreInfo => 'Meer info';

  @override
  String scaleOriginal(String servings) {
    return 'Origineel: $servings';
  }

  @override
  String get scaleAdjustQuantities => 'Ingrediënthoeveelheden aanpassen';

  @override
  String get scaleOriginalLabel => '1x (Origineel)';

  @override
  String get stepWillBeRemoved => 'Deze stap wordt permanent verwijderd.';

  @override
  String stepsWillBeRemoved(int count) {
    return 'Deze $count stappen worden permanent verwijderd.';
  }

  @override
  String stepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stappen',
      one: '1 stap',
    );
    return '$_temp0';
  }

  @override
  String get instructionsNoSteps => 'Nog geen instructies';

  @override
  String get instructionsAddStepsGuide => 'Voeg stappen toe om door het recept te leiden';

  @override
  String get pinchToZoomPreview => 'Knijp om te zoomen · Zo ziet je foto eruit';

  @override
  String ingredientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingrediënten',
      one: '1 ingrediënt',
    );
    return '$_temp0';
  }

  @override
  String get ingredientPerLineHint => 'Voer één ingrediënt per regel in:\n\n2 kopjes bloem\n1 tl zout\n3 eieren';

  @override
  String get ingredientTip => 'Tip: Voer één ingrediënt per regel in. Druk na elk ingrediënt op Enter.';

  @override
  String get cookbookEditSubtitle => 'Hernoemen, omslagfoto';

  @override
  String get shareCookbookSubtitle => 'Link, familie of community';

  @override
  String shareNamedCookbook(String name) {
    return '\"$name\" delen';
  }

  @override
  String shareNamedList(String name) {
    return '\"$name\" delen';
  }

  @override
  String get shareAsTextDescription => 'Lijstitems als tekst versturen';

  @override
  String get oneTimeLink => 'Eenmalige link';

  @override
  String get oneTimeLinkDescription => 'Gratis • 24 uur geldig • Iedereen kan downloaden';

  @override
  String get familyShare => 'Gezinsdeling';

  @override
  String get familyShareDescription => 'Realtime synchronisatie met gezinsleden';

  @override
  String get postToCommunity => 'Publiceren naar Community';

  @override
  String get postToCommunityDescription => 'Publiceer zodat iedereen het kan ontdekken en downloaden';

  @override
  String get signInToShare => 'Inloggen om deellinks te maken';

  @override
  String get generatingLink => 'Link wordt gegenereerd...';

  @override
  String get failedToCreateLink => 'Link aanmaken mislukt';

  @override
  String get linkCreated => 'Link aangemaakt!';

  @override
  String get expiresIn24Hours => 'Verloopt over 24 uur';

  @override
  String get linkCopied => 'Link gekopieerd!';

  @override
  String unlockFeature(String feature) {
    return '$feature ontgrendelen';
  }

  @override
  String get notNow => 'Niet nu';

  @override
  String get upgradeButton => 'Upgraden';

  @override
  String publishMinRecipes(int count) {
    return 'Minimaal 10 recepten nodig (heeft $count)';
  }

  @override
  String get publishConfirmTitle => 'Publiceren naar Community?';

  @override
  String publishConfirmMessage(String name, int count) {
    return '\"$name\" ($count recepten) wordt openbaar zichtbaar. Iedereen kan het bekijken en downloaden.\n\nJe kunt het altijd verwijderen via Community → Mijn publicaties.';
  }

  @override
  String get publishButton => 'Publiceren';

  @override
  String get selectCourse => 'Gang selecteren';

  @override
  String get selectCategory => 'Categorie selecteren';

  @override
  String get taxonomyNone => 'Geen';

  @override
  String createTaxonomy(String name) {
    return '\"$name\" aanmaken';
  }

  @override
  String get addAsNewCourse => 'Toevoegen als nieuwe gang';

  @override
  String get addAsNewCategory => 'Toevoegen als nieuwe categorie';

  @override
  String doneWithCount(int count) {
    return 'Klaar ($count)';
  }

  @override
  String get quickAccessEmptyAll => 'Nog geen snelle-toegangsrecepten';

  @override
  String get quickAccessEmptyMealPlan => 'Geen maaltijden gepland';

  @override
  String get quickAccessEmptyPinned => 'Geen vastgezette recepten';

  @override
  String get quickAccessEmptyRecent => 'Geen recente recepten';

  @override
  String get importingRecipe => 'Recept importeren…';

  @override
  String errorWithMessage(String message) {
    return 'Fout: $message';
  }

  @override
  String get minutesPrepSuffix => 'm prep';

  @override
  String get minutesCookSuffix => 'm koken';

  @override
  String get couldNotOpenBrowser => 'Kan browser niet openen';

  @override
  String couldNotOpenUrl(String url) {
    return 'Kan $url niet openen';
  }

  @override
  String get discord => 'Discord';

  @override
  String get discordLinkAccount => 'Discord-account koppelen';

  @override
  String get discordLinkSubtitle => 'Koppel je Discord voor communityfuncties';

  @override
  String get discordSignInFirst => 'Log eerst in om Discord te koppelen';

  @override
  String get discordUnlink => 'Discord ontkoppelen';

  @override
  String get discordUnlinkFailed => 'Discord ontkoppelen mislukt';

  @override
  String get discordUnlinkSubtitle => 'Je Discord-verbinding verwijderen';

  @override
  String get discordUnlinked => 'Discord ontkoppeld';

  @override
  String get familyCodeCopied => 'Uitnodigingscode gekopieerd!';

  @override
  String get familyCopyLink => 'Link kopiëren';

  @override
  String get familyCreate => 'Gezin aanmaken';

  @override
  String get familyCreateFailed => 'Gezin aanmaken mislukt';

  @override
  String get familyCreateTitle => 'Gezin aanmaken';

  @override
  String get familyCreated => 'Gezin aangemaakt!';

  @override
  String get familyDelete => 'Gezin verwijderen';

  @override
  String get familyDeleteConfirm => 'Weet je zeker dat je dit gezin wilt verwijderen? Alle leden worden verwijderd.';

  @override
  String get familyDeleted => 'Gezin verwijderd';

  @override
  String get familyEnterInviteCode => 'Uitnodigingscode invoeren';

  @override
  String get familyInvite => 'Leden uitnodigen';

  @override
  String get familyJoinAction => 'Deelnemen';

  @override
  String get familyJoinFailed => 'Deelnemen aan gezin mislukt';

  @override
  String get familyJoinTitle => 'Gezin bijtreden';

  @override
  String get familyJoinWithCode => 'Met code deelnemen';

  @override
  String familyJoined(String familyName) {
    return 'Aangesloten bij $familyName!';
  }

  @override
  String get familyLeave => 'Gezin verlaten';

  @override
  String get familyLeaveAction => 'Verlaten';

  @override
  String get familyLeaveConfirm => 'Weet je zeker dat je dit gezin wilt verlaten?';

  @override
  String get familyLeft => 'Gezin verlaten';

  @override
  String get familyLinkCopied => 'Uitnodigingslink gekopieerd!';

  @override
  String get familyManage => 'Je gezin beheren';

  @override
  String familyMemberRemoved(String displayName) {
    return '$displayName verwijderd';
  }

  @override
  String get familyMembers => 'Leden';

  @override
  String familyMembersCount(int current, int max) {
    return '$current van $max leden';
  }

  @override
  String get familyNameHint => 'Gezinsnaam';

  @override
  String get familyNewCodeGenerated => 'Nieuwe uitnodigingscode gegenereerd';

  @override
  String get familyOwner => 'EIGENAAR';

  @override
  String get familyRegenerateCode => 'Code opnieuw genereren';

  @override
  String get familyRemoveMember => 'Lid verwijderen';

  @override
  String familyRemoveMemberConfirm(String displayName) {
    return '$displayName uit het gezin verwijderen?';
  }

  @override
  String get familyRename => 'Gezin hernoemen';

  @override
  String familyShareMessage(String inviteCode, String shareLink) {
    return 'Doe mee met mijn gezin op Recipe Spellbook! Code: $inviteCode of gebruik deze link: $shareLink';
  }

  @override
  String get familyShareSubject => 'Doe mee met mijn Recipe Spellbook-gezin';

  @override
  String get familyShareUpgradeMessage => 'Upgrade om kookboeken in realtime te delen met gezinsleden.';

  @override
  String get familySharing => 'Gezinsdeling';

  @override
  String get familySharingDescription => 'Deel kookboeken, boodschappenlijsten en maaltijdplannen met je gezin.';

  @override
  String get familySharingSubtitle => 'Kookboeken, lijsten & maaltijdplannen delen';

  @override
  String ingredientSubstitutesFor(String ingredientName) {
    return 'Vervangers voor $ingredientName';
  }

  @override
  String get ingredientSubstitutionsNoResults => 'Geen vervangers gevonden';

  @override
  String ingredientSubstitutionsNotFound(String ingredientName) {
    return 'Geen vervangers gevonden voor $ingredientName';
  }

  @override
  String get ingredientSubstitutionsTryDifferent => 'Probeer een ander ingrediënt';

  @override
  String get integrationsChecking => 'Controleren...';

  @override
  String get integrationsConnectedManage => 'Verbonden – Tik om te beheren';

  @override
  String get integrationsLinked => 'Gekoppeld';

  @override
  String get integrationsLinkedManage => 'Gekoppeld – Tik om te beheren';

  @override
  String get integrationsNotConnected => 'Niet verbonden';

  @override
  String get integrationsTapToLink => 'Tik om te koppelen';

  @override
  String get integrationsTapToSignIn => 'Tik om in te loggen';

  @override
  String get nutritionCalculateFromEdit => 'Berekenen vanuit het bewerkingsscherm';

  @override
  String get nutritionCaloriesAlwaysShow => 'Calorieën altijd tonen';

  @override
  String get nutritionChartStyle => 'Grafiekstijl';

  @override
  String get nutritionResetDefaults => 'Standaardwaarden herstellen';

  @override
  String get nutritionSettingsLink => 'Voedingsinstellingen';

  @override
  String get nutritionTapToCalculate => 'Tik om voeding te berekenen';

  @override
  String get nutritionVisibleNutrients => 'Zichtbare voedingsstoffen';

  @override
  String pantryAddedStaples(int count) {
    return '$count basisproducten toegevoegd aan voorraadkast';
  }

  @override
  String get pantryClearAll => 'Alles wissen';

  @override
  String get pantryClearMessage => 'Alle items uit je voorraadkast verwijderen?';

  @override
  String get pantryCommonStaples => 'Veel voorkomende basisproducten';

  @override
  String get pantryEmpty => 'Je voorraadkast is leeg';

  @override
  String get pantryEmptySubtitle => 'Voeg items toe die je altijd in huis hebt';

  @override
  String get pantryInfoMessage => 'Items in je voorraadkast worden uitgesloten van boodschappenlijsten wanneer je receptingrediënten toevoegt.';

  @override
  String pantryItemCount(int count) {
    return '$count items';
  }

  @override
  String get mealPlanAddTitle => 'Toevoegen aan maaltijdplan';

  @override
  String get mealPlanMealLabel => 'Maaltijd';

  @override
  String get mealPlanAdding => 'Toevoegen...';

  @override
  String mealPlanDateFormat(String weekday, String month, int day) {
    return '$weekday $day $month';
  }

  @override
  String get splashRecipe => 'Recept';

  @override
  String get splashSpellbook => 'Spreukenboek';

  @override
  String get splashTagline => 'Je culinaire avontuur wacht';

  @override
  String get servingSizeHint => 'bijv. 1 kopje, 100g';

  @override
  String get mainNutrients => 'Hoofdvoedingsstoffen';

  @override
  String get additionalNutrients => 'Overige voedingsstoffen';

  @override
  String get onboardingWelcomeTo => 'Welkom bij';

  @override
  String get onboardingAppName => 'Recipe Spellbook!';

  @override
  String get onboardingDescription => '10 zorgvuldig geselecteerde recepten van over de hele wereld om mee te beginnen.';

  @override
  String get onboardingDeleteLater => 'Je kunt ze later altijd verwijderen.';

  @override
  String get onboardingAdding => 'Toevoegen...';

  @override
  String get onboardingAddStarter => 'Startrecepten toevoegen';

  @override
  String get onboardingBlankCookbook => 'Begin met een leeg kookboek';

  @override
  String get onboardingBlankConfirmTitle => 'Start with nothing?';

  @override
  String get onboardingBlankConfirmBody => 'You can always add the starter recipes later from Settings.';

  @override
  String get onboardingBlankConfirmYes => 'Yes, start empty';

  @override
  String get onboardingSpellbookAwaits => 'Je spreukenboek wacht';

  @override
  String get onboardingYourSpellbookAwaits => 'Je spreukenboek wacht...';

  @override
  String get onboardingSummoning => 'Oproepen...';

  @override
  String get onboardingBlankSpellbook => 'Begin met een leeg spreukenboek';

  @override
  String get onboardingSkip => 'Overslaan';

  @override
  String get settingsBrowseCommunity => 'Community verkennen';

  @override
  String get settingsBrowseCommunitySubtitle => 'Openbare kookboeken ontdekken';

  @override
  String get settingsCommunity => 'Community';

  @override
  String get settingsFamily => 'Gezin';

  @override
  String get settingsIntegrations => 'Integraties';

  @override
  String get settingsMyPublications => 'Mijn publicaties';

  @override
  String get settingsMyPublicationsSubtitle => 'Gepubliceerde kookboeken beheren';

  @override
  String get settingsShoppingPlanning => 'Boodschappen & Planning';

  @override
  String shoppingAddCountItems(int count) {
    return '$count items toevoegen';
  }

  @override
  String get shoppingAddIngredient => 'Ingrediënt toevoegen';

  @override
  String shoppingAddedItemName(String name) {
    return '\"$name\" toegevoegd';
  }

  @override
  String shoppingAddedNotFound(int added, int failed) {
    return '$added toegevoegd, $failed niet gevonden';
  }

  @override
  String shoppingAddingTo(String provider) {
    return 'Toevoegen aan $provider…';
  }

  @override
  String get shoppingCamera => 'camera';

  @override
  String shoppingCheckedItemsCount(int count) {
    return 'Aangevinkte items ($count)';
  }

  @override
  String shoppingCouldNotAccessSource(String source) {
    return 'Kan geen toegang krijgen tot $source';
  }

  @override
  String shoppingCountAdded(int count) {
    return '$count toegevoegd';
  }

  @override
  String shoppingCreatingListOn(String provider) {
    return 'Lijst aanmaken op $provider…';
  }

  @override
  String shoppingCurrentOfTotal(int current, int total) {
    return '$current van $total items';
  }

  @override
  String shoppingDeleteListConfirm(String name) {
    return 'Weet je zeker dat je \"$name\" wilt verwijderen?';
  }

  @override
  String shoppingErrorReadingImage(String error) {
    return 'Fout bij lezen afbeelding: $error';
  }

  @override
  String shoppingExportFailed(String error) {
    return 'Exporteren mislukt: $error';
  }

  @override
  String shoppingExportTitle(String name) {
    return '\"$name\" exporteren';
  }

  @override
  String get shoppingFamilyShare => 'Gezinsdeling';

  @override
  String get shoppingFamilyShareSubtitle => 'Lijst delen met gezin of eenmalige link';

  @override
  String get shoppingFromPhoto => 'Van foto';

  @override
  String get shoppingFromText => 'Van tekst';

  @override
  String get shoppingGallery => 'galerij';

  @override
  String get shoppingImportItems => 'Items importeren';

  @override
  String get shoppingImportShoppingList => 'Boodschappenlijst importeren';

  @override
  String get shoppingImportTextHint => '2 kopjes bloem\nkipfilet\n500g gehakt\nmelk\n...';

  @override
  String get shoppingImportedList => 'Geïmporteerde lijst';

  @override
  String get shoppingIngredientHint => 'bijv. kipfilet, olijfolie';

  @override
  String get shoppingIngredientName => 'Ingrediëntnaam';

  @override
  String shoppingIngredientsAvailable(int count) {
    return '$count ingrediënten beschikbaar';
  }

  @override
  String shoppingItemsAddedCount(int count) {
    return '$count items toegevoegd';
  }

  @override
  String get shoppingItemsAddedSuccess => 'Items toegevoegd!';

  @override
  String shoppingItemsCopiedToClipboard(int count) {
    return '$count items gekopieerd naar klembord';
  }

  @override
  String shoppingItemsInCart(int count, String provider) {
    return '$count items in je $provider-winkelwagen';
  }

  @override
  String shoppingItemsOnInstacartList(int count) {
    return '$count items op je Instacart-lijst';
  }

  @override
  String get shoppingJustAdded => 'Zojuist toegevoegd';

  @override
  String shoppingListCopiedOpening(String name) {
    return 'Lijst gekopieerd! $name openen...';
  }

  @override
  String get shoppingListReady => 'Boodschappenlijst klaar!';

  @override
  String shoppingNotFoundItems(String items) {
    return 'Niet gevonden: $items';
  }

  @override
  String get shoppingOneItemPerLine => 'Eén item per regel';

  @override
  String get shoppingPartiallyAdded => 'Gedeeltelijk toegevoegd';

  @override
  String get shoppingProviderConnected => 'Verbonden';

  @override
  String get shoppingRemoveFromList => 'Verwijderen van lijst';

  @override
  String get shoppingStartTyping => 'Begin te typen voor suggesties';

  @override
  String get shoppingTapToAddToCart => 'Tik om items direct aan je winkelwagen toe te voegen';

  @override
  String get shoppingTapToCreateShoppableList => 'Tik om een boodschappenlijst te maken';

  @override
  String get swipeToSwitch => 'Veeg om van sectie te wisselen';

  @override
  String get syncFailed => 'Synchronisatie mislukt';

  @override
  String syncSuccess(int pushed, int pulled) {
    return 'Gesynchroniseerd: $pushed verzonden, $pulled ontvangen';
  }

  @override
  String get textSizePreview => 'Voorbeeld';

  @override
  String get transferDeviceDesktop => 'desktop';

  @override
  String get transferDeviceMobileApp => 'mobiele app';

  @override
  String get transferDeviceThisDevice => 'dit apparaat';

  @override
  String transferExplanation(String currentDevice, String targetDevice) {
    return 'Verplaats al je recepten, kookboeken en maaltijdplannen van $currentDevice naar je $targetDevice. Dit is een eenmalige kopie, geen synchronisatie.';
  }

  @override
  String transferImportedSuccess(int count) {
    return '$count items succesvol geïmporteerd.';
  }

  @override
  String get transferOr => 'OF';

  @override
  String transferReceiveOn(String device) {
    return 'Ontvangen op $device';
  }

  @override
  String transferSendFrom(String device) {
    return 'Verzenden vanaf $device';
  }

  @override
  String transferSendSubtitle(String device) {
    return 'Genereer een code die je $device kan ontvangen';
  }

  @override
  String get importGuidesTitle => 'Importgidsen';

  @override
  String get importGuidesOpenInBrowser => 'Gidsen openen in browser';

  @override
  String get importGuideHeroTitle => 'Breng je recepten van overal';

  @override
  String get importGuideHeroSubtitle => 'Tik op een gids hieronder voor stap-voor-stap instructies met schermafbeeldingen.';

  @override
  String get importGuideQuickTipLabel => 'Snelle tip';

  @override
  String get importGuideQuickTipText => 'De snelste manier? Kopieer een receptlink en deel het met Recipe Spellbook — werkt vanuit bijna elke app.';

  @override
  String get importGuideWebButton => 'Web';

  @override
  String get importGuideFollowInBrowser => 'Volg in browser';

  @override
  String get importGuideTagPopular => 'Populair';

  @override
  String get importGuideTagEasiest => 'Makkelijkst';

  @override
  String get importGuideDifficultyEasy => 'Makkelijk';

  @override
  String get importGuideDifficultyMedium => 'Gemiddeld';

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
    return '$count stappen';
  }

  @override
  String get importGuideCategorySocial => 'Sociale media';

  @override
  String get importGuideCategoryWebsites => 'Websites';

  @override
  String get importGuideCategoryPhotos => 'Foto\'s & Bestanden';

  @override
  String get importGuideCategoryOtherApps => 'Andere recepten-apps';

  @override
  String get importGuideCategoryAi => 'AI-import';

  @override
  String get importGuideTagNew => 'Nieuw';

  @override
  String get importGuideScreenshotNeeded => 'Schermafbeelding nodig';

  @override
  String get importGuideGifNeeded => 'GIF nodig';

  @override
  String get importGuideVideoNeeded => 'Video nodig';

  @override
  String get importGuideInstagramTitle => 'Instagram';

  @override
  String get importGuideInstagramSubtitle => 'Importeren vanuit Reels, berichten en stories';

  @override
  String get importGuideInstagramStep1Title => 'Zoek een receptbericht of Reel';

  @override
  String get importGuideInstagramStep1Desc => 'Open Instagram en zoek een recept dat je wilt opslaan. Dit werkt met feedberichten, Reels en carrousels.';

  @override
  String get importGuideInstagramStep2Title => 'Tik op de deelknop';

  @override
  String get importGuideInstagramStep2Desc => 'Tik op het papiervliegtuigpictogram (delen) onder het bericht.';

  @override
  String get importGuideInstagramStep3Title => 'Delen naar Recipe Spellbook';

  @override
  String get importGuideInstagramStep3Desc => 'Scrol door de app-rij en tik op Recipe Spellbook. Als je het niet ziet, tik op \"Meer\" en zoek het in de lijst.';

  @override
  String get importGuideInstagramStep3Tip => 'Op Android kun je ook de link kopiëren en in de app plakken.';

  @override
  String get importGuideInstagramStep4Title => 'Het geëxtraheerde recept bekijken';

  @override
  String get importGuideInstagramStep4Desc => 'Onze AI leest het bijschrift, hashtags en tekst in de afbeelding om je recept samen te stellen. Controleer ingrediënten en stappen en sla op.';

  @override
  String get importGuideInstagramStep5Title => 'Kookboek kiezen & opslaan';

  @override
  String get importGuideInstagramStep5Desc => 'Kies in welk kookboek je wilt opslaan, voeg labels toe en tik op Opslaan. Klaar!';

  @override
  String get importGuideTiktokTitle => 'TikTok';

  @override
  String get importGuideTiktokSubtitle => 'Recepten opslaan van kookvideo\'s';

  @override
  String get importGuideTiktokStep1Title => 'Zoek een recept-TikTok';

  @override
  String get importGuideTiktokStep1Desc => 'Open TikTok en zoek een kookvideo die je wilt opslaan.';

  @override
  String get importGuideTiktokStep2Title => 'Tik op de deelpijl';

  @override
  String get importGuideTiktokStep2Desc => 'Tik op het pijlpictogram rechts van de video.';

  @override
  String get importGuideTiktokStep3Title => 'Kies \"Link kopiëren\" of deel direct';

  @override
  String get importGuideTiktokStep3Desc => 'Tik op \"Link kopiëren\" en plak in Recipe Spellbook, of zoek Recipe Spellbook in de deelopties.';

  @override
  String get importGuideTiktokStep3Tip => '\"Link kopiëren\" is vaak de betrouwbaarste methode voor TikTok.';

  @override
  String get importGuideTiktokStep4Title => 'Link plakken in Recipe Spellbook';

  @override
  String get importGuideTiktokStep4Desc => 'Open Recipe Spellbook, tik op +, kies \"Van website/link\" en plak de TikTok-URL.';

  @override
  String get importGuideTiktokStep5Title => 'Bekijken & opslaan';

  @override
  String get importGuideTiktokStep5Desc => 'De AI haalt het recept uit de videobeschrijving en reacties. Bekijk en sla op in je kookboek.';

  @override
  String get importGuideYoutubeTitle => 'YouTube';

  @override
  String get importGuideYoutubeSubtitle => 'Importeren vanuit kookkanalen & Shorts';

  @override
  String get importGuideYoutubeStep1Title => 'Zoek een receptvideo';

  @override
  String get importGuideYoutubeStep1Desc => 'Open YouTube en zoek een kookvideo. Werkt met gewone video\'s, Shorts en livestream-replays.';

  @override
  String get importGuideYoutubeStep2Title => 'Tik op Delen';

  @override
  String get importGuideYoutubeStep2Desc => 'Tik op de deelknop onder de videotitel.';

  @override
  String get importGuideYoutubeStep3Title => 'Link kopiëren of delen naar app';

  @override
  String get importGuideYoutubeStep3Desc => 'Tik op \"Link kopiëren\" of zoek Recipe Spellbook in het deelmenu.';

  @override
  String get importGuideYoutubeStep3Tip => 'Veel YouTube-creators zetten het volledige recept in de videobeschrijving — dit maakt extractie nauwkeuriger.';

  @override
  String get importGuideYoutubeStep4Title => 'Plakken & importeren';

  @override
  String get importGuideYoutubeStep4Desc => 'Tik in Recipe Spellbook op + > \"Van website/link\" en plak. De AI leest de videobeschrijving voor ingrediënten en stappen.';

  @override
  String get importGuidePinterestTitle => 'Pinterest';

  @override
  String get importGuidePinterestSubtitle => 'Vastgepinde recepten opslaan in je kookboek';

  @override
  String get importGuidePinterestStep1Title => 'Open een receptpin';

  @override
  String get importGuidePinterestStep1Desc => 'Tik op een receptpin om deze te openen. De meeste pins linken naar de originele receptwebsite.';

  @override
  String get importGuidePinterestStep2Title => 'Tik op de bronlink';

  @override
  String get importGuidePinterestStep2Desc => 'Tik op de link boven- of onderaan de pin om de originele receptpagina te bezoeken.';

  @override
  String get importGuidePinterestStep2Tip => 'Als de pin geen bronlink heeft, probeer dan de deelmethode hieronder.';

  @override
  String get importGuidePinterestStep3Title => 'Website-URL kopiëren';

  @override
  String get importGuidePinterestStep3Desc => 'Zodra de receptwebsite in je browser is geopend, kopieer de URL uit de adresbalk.';

  @override
  String get importGuidePinterestStep4Title => 'Importeren in Recipe Spellbook';

  @override
  String get importGuidePinterestStep4Desc => 'Tik op + > \"Van website/link\", plak de URL en het recept wordt automatisch geëxtraheerd.';

  @override
  String get importGuideWebsiteTitle => 'Elke receptwebsite';

  @override
  String get importGuideWebsiteSubtitle => 'AllRecipes, Food Network, BBC, blogs & meer';

  @override
  String get importGuideWebsiteStep1Title => 'Open de receptpagina';

  @override
  String get importGuideWebsiteStep1Desc => 'Navigeer naar een recept op sites zoals AllRecipes, Food Network, BBC Good Food, Serious Eats, NYT Cooking of een foodblog.';

  @override
  String get importGuideWebsiteStep2Title => 'URL kopiëren';

  @override
  String get importGuideWebsiteStep2Desc => 'Tik op de adresbalk en kopieer de volledige URL naar het recept.';

  @override
  String get importGuideWebsiteStep3Title => 'Tik op + in Recipe Spellbook';

  @override
  String get importGuideWebsiteStep3Desc => 'Open de app en tik op de + knop om een nieuw recept toe te voegen.';

  @override
  String get importGuideWebsiteStep4Title => 'Kies \"Van website/link\"';

  @override
  String get importGuideWebsiteStep4Desc => 'Selecteer de website-importoptie en plak je gekopieerde URL.';

  @override
  String get importGuideWebsiteStep5Title => 'Bekijken & opslaan';

  @override
  String get importGuideWebsiteStep5Desc => 'Het recept wordt direct geëxtraheerd — titel, ingrediënten, stappen, kooktijden en zelfs de foto. Bekijk en sla op.';

  @override
  String get importGuideWebsiteStep5Tip => 'Werkt met meer dan 10.000 receptsites. Als extractie mislukt, probeer dan de \"Van tekst\"-methode.';

  @override
  String get importGuidePhotoTitle => 'Foto / Camera';

  @override
  String get importGuidePhotoSubtitle => 'Recepten scannen van boeken, tijdschriften of handgeschreven kaarten';

  @override
  String get importGuidePhotoStep1Title => 'Fotografeer het recept';

  @override
  String get importGuidePhotoStep1Desc => 'Maak een duidelijke, goed verlichte foto van een recept uit een kookboek, tijdschrift of handgeschreven receptkaart. Zorg dat alle tekst leesbaar is.';

  @override
  String get importGuidePhotoStep1Tip => 'Voor het beste resultaat: goede verlichting, stilhouden en het hele recept in beeld. Vermijd schaduwen.';

  @override
  String get importGuidePhotoStep2Title => 'Tik op + dan \"Van foto\"';

  @override
  String get importGuidePhotoStep2Desc => 'Open Recipe Spellbook, tik op + en kies \"Van foto\". Selecteer de foto uit je galerij of maak een nieuwe.';

  @override
  String get importGuidePhotoStep3Title => 'AI scant de tekst';

  @override
  String get importGuidePhotoStep3Desc => 'OCR-technologie leest de tekst in je foto en AI scheidt intelligent de titel, ingrediënten en instructies.';

  @override
  String get importGuidePhotoStep4Title => 'Bekijken & fouten corrigeren';

  @override
  String get importGuidePhotoStep4Desc => 'Controleer het geëxtraheerde recept. OCR leest soms tekens verkeerd — \"1/2\" kan \"1l2\" worden. Corrigeer fouten en sla op.';

  @override
  String get importGuidePhotoStep4Tip => 'Handgeschreven recepten werken ook, maar gedrukte tekst geeft de beste resultaten.';

  @override
  String get importGuidePdfTitle => 'PDF-document';

  @override
  String get importGuidePdfSubtitle => 'Importeren vanuit PDF-kookboeken of downloads';

  @override
  String get importGuidePdfStep1Title => 'Een recept-PDF gereed hebben';

  @override
  String get importGuidePdfStep1Desc => 'Dit werkt met gedownloade recept-PDF\'s, e-book kookboeken, gescande documenten of PDF\'s gedeeld via e-mail.';

  @override
  String get importGuidePdfStep2Title => 'Tik op + dan \"Van PDF\"';

  @override
  String get importGuidePdfStep2Desc => 'Open Recipe Spellbook, tik op +, kies \"Van PDF\" en selecteer je bestand.';

  @override
  String get importGuidePdfStep3Title => 'Selecteer de receptpagina';

  @override
  String get importGuidePdfStep3Desc => 'Als de PDF meerdere pagina\'s heeft, kies welke pagina het recept bevat dat je wilt importeren.';

  @override
  String get importGuidePdfStep4Title => 'Bekijken & opslaan';

  @override
  String get importGuidePdfStep4Desc => 'Het recept wordt uit de PDF geëxtraheerd. Bekijk de ingrediënten en stappen en sla op in je kookboek.';

  @override
  String get importGuideTextTitle => 'Tekst / Plakken';

  @override
  String get importGuideTextSubtitle => 'Een recept plakken van berichten, e-mail of notities';

  @override
  String get importGuideTextStep1Title => 'Recepttekst kopiëren';

  @override
  String get importGuideTextStep1Desc => 'Kopieer de recepttekst van een SMS, e-mail, notitie-app, WhatsApp of ergens anders.';

  @override
  String get importGuideTextStep2Title => 'Tik op + dan \"Van tekst\"';

  @override
  String get importGuideTextStep2Desc => 'Open Recipe Spellbook, tik op + en kies \"Van tekst\".';

  @override
  String get importGuideTextStep3Title => 'Je recept plakken';

  @override
  String get importGuideTextStep3Desc => 'Plak de gekopieerde tekst in het tekstveld. De AI scheidt automatisch de titel, ingrediënten en stappen.';

  @override
  String get importGuideTextStep3Tip => 'Dit werkt zelfs met onopgemaakte tekst — de AI is slim in het herkennen van hoeveelheden en stapinstructies.';

  @override
  String get importGuideTextStep4Title => 'Bekijken & opslaan';

  @override
  String get importGuideTextStep4Desc => 'Controleer het verwerkte recept, pas aan en sla op.';

  @override
  String get importGuideAiTitle => 'AI (ChatGPT, Claude, etc.)';

  @override
  String get importGuideAiSubtitle => 'Genereer recepten met AI en importeer ze direct';

  @override
  String get importGuideAiStep1Title => 'Open AI-import';

  @override
  String get importGuideAiStep1Desc => 'Ga naar Home, tik op + om een recept toe te voegen, kies Importeren en tik vervolgens op de AI-knop.';

  @override
  String get importGuideAiStep2Title => 'Kopieer de prompt';

  @override
  String get importGuideAiStep2Desc => 'Tik op de knop prompt kopiëren. Open vervolgens je favoriete AI — ChatGPT, Claude, Gemini of een andere — en plak de prompt.';

  @override
  String get importGuideAiStep3Title => 'Kopieer het antwoord van de AI';

  @override
  String get importGuideAiStep3Desc => 'De AI genereert een recept in JSON-formaat. Kopieer het volledige antwoord.';

  @override
  String get importGuideAiStep4Title => 'Plak in Recipe Spellbook';

  @override
  String get importGuideAiStep4Desc => 'Ga terug naar Recipe Spellbook, tik op de plakknop en tik vervolgens op Voorbeeld om het verwerkte recept te bekijken.';

  @override
  String get importGuideAiStep5Title => 'Voorbeeld bekijken & importeren';

  @override
  String get importGuideAiStep5Desc => 'Controleer of alles er goed uitziet en tik vervolgens op Importeren om het recept in je kookboek op te slaan.';

  @override
  String get importGuideOtherAppsTitle => 'Andere recepten-apps';

  @override
  String get importGuideOtherAppsSubtitle => 'Mealime, CopyMeThat, AnyList, Cookmate enz.';

  @override
  String get importGuideOtherAppsStep1Title => 'Exporteren vanuit je huidige app';

  @override
  String get importGuideOtherAppsStep1Desc => 'De meeste recepten-apps ondersteunen exporteren naar JSON, HTML of tekst. Controleer Instellingen > Exporteren of Back-up.';

  @override
  String get importGuideOtherAppsStep1Tip => 'Veelgebruikte formaten: JSON (het beste), HTML, PDF of platte tekst. JSON behoudt de meeste gegevens.';

  @override
  String get importGuideOtherAppsStep2Title => 'Bestand op je apparaat krijgen';

  @override
  String get importGuideOtherAppsStep2Desc => 'Sla het geëxporteerde bestand op of zet het over naar je telefoon via e-mail, cloudopslag of een andere methode.';

  @override
  String get importGuideOtherAppsStep3Title => 'Importeren via Instellingen';

  @override
  String get importGuideOtherAppsStep3Desc => 'Ga in Recipe Spellbook naar Instellingen > Gegevens > Importeren en selecteer het geëxporteerde bestand. De app verwerkt JSON, HTML en gangbare receptformaten.';

  @override
  String get importGuideOtherAppsStep4Title => 'Je recepten controleren';

  @override
  String get importGuideOtherAppsStep4Desc => 'Geïmporteerde recepten verschijnen in je standaardkookboek. Je kunt ze daarna indelen in verschillende kookboeken.';

  @override
  String get importGuideDeviceTransferTitle => 'Apparaatoverdracht';

  @override
  String get importGuideDeviceTransferSubtitle => 'Recepten overzetten tussen telefoons zonder account';

  @override
  String get importGuideDeviceTransferStep1Title => 'Open Overdracht op het OUDE apparaat';

  @override
  String get importGuideDeviceTransferStep1Desc => 'Open op je oude telefoon Recipe Spellbook en ga naar Menu > Apparaatoverdracht > Verzenden.';

  @override
  String get importGuideDeviceTransferStep2Title => 'Overdrachtscode ophalen';

  @override
  String get importGuideDeviceTransferStep2Desc => 'Een 6-tekencode wordt gegenereerd. Deze code is 15 minuten geldig.';

  @override
  String get importGuideDeviceTransferStep3Title => 'Code invoeren op NIEUW apparaat';

  @override
  String get importGuideDeviceTransferStep3Desc => 'Installeer Recipe Spellbook op je nieuwe telefoon en ga naar Menu > Apparaatoverdracht > Ontvangen. Voer de code in.';

  @override
  String get importGuideDeviceTransferStep4Title => 'Recepten overgezet!';

  @override
  String get importGuideDeviceTransferStep4Desc => 'Al je recepten, kookboeken, boodschappenlijsten en maaltijdplannen worden overgezet naar het nieuwe apparaat.';

  @override
  String get importGuideDeviceTransferStep4Tip => 'Een betaald account? Log gewoon in op het nieuwe apparaat en alles wordt automatisch gesynchroniseerd.';

  @override
  String get faqTitle => 'FAQ\'s';

  @override
  String get faqHeroTitle => 'Veelgestelde vragen';

  @override
  String get faqHeroSubtitle => 'Vind antwoorden en stapsgewijze handleidingen voor veelgebruikte functies.';

  @override
  String get faqHowToGuides => 'Handleidingen';

  @override
  String get faqCommonQuestions => 'Veelgestelde vragen';

  @override
  String get faqSeeHowTo => 'Bekijk de handleiding';

  @override
  String faqStepsCount(int count) {
    return '$count stappen';
  }

  @override
  String get faqAddHeadersTitle => 'Hoe voeg je koppen toe';

  @override
  String get faqAddHeadersSubtitle => 'Organiseer je receptingrediënten en -stappen in secties';

  @override
  String get faqAddHeadersStep1Title => 'Open de recepteditor';

  @override
  String get faqAddHeadersStep1Desc => 'Open een recept en tik op het bewerkicoon.';

  @override
  String get faqAddHeadersStep2Title => 'Voeg een kop toe';

  @override
  String get faqAddHeadersStep2Desc => 'Tik op de knop \'Kop toevoegen\' om een sectiekop in te voegen.';

  @override
  String get faqAddHeadersStep3Title => 'Open het kopmenu';

  @override
  String get faqAddHeadersStep3Desc => 'Tik op de drie puntjes (⋮) naast de kop voor meer opties.';

  @override
  String get faqAddHeadersStep4Title => 'Herorden je koppen';

  @override
  String get faqAddHeadersStep4Desc => 'Tik op Sorteervolgorde om te herschikken. Sleep het ≡-handvat om koppen omhoog of omlaag te verplaatsen.';

  @override
  String get faqAddHeadersStep4Tip => 'Je kunt koppen slepen door het ≡ (twee lijnen) handvat aan de linkerkant ingedrukt te houden.';

  @override
  String get faqAddHeadersStep5Title => 'Sla je wijzigingen op';

  @override
  String get faqAddHeadersStep5Desc => 'Tik op de opslaanknop om je nieuwe koppen te bewaren.';

  @override
  String get faqAddHeadersStep6Title => 'Klaar!';

  @override
  String get faqAddHeadersStep6Desc => 'Je recept heeft nu georganiseerde secties met koppen.';

  @override
  String get faqAddSublinkedTitle => 'Hoe voeg je gekoppelde recepten toe';

  @override
  String get faqAddSublinkedSubtitle => 'Koppel gerelateerde recepten aan elkaar voor snelle toegang';

  @override
  String get faqAddSublinkedStep1Title => 'Open de recepteditor';

  @override
  String get faqAddSublinkedStep1Desc => 'Open een recept en tik op het bewerkicoon.';

  @override
  String get faqAddSublinkedStep2Title => 'Open het menu';

  @override
  String get faqAddSublinkedStep2Desc => 'Tik op de drie puntjes (⋮) in het bewerkscherm.';

  @override
  String get faqAddSublinkedStep3Title => 'Tik op Recept koppelen';

  @override
  String get faqAddSublinkedStep3Desc => 'Selecteer \'Recept koppelen\' in het menu.';

  @override
  String get faqAddSublinkedStep4Title => 'Kies een recept om te koppelen';

  @override
  String get faqAddSublinkedStep4Desc => 'Tik op het koppelingspictogram naast het recept dat je wilt verbinden (bijv. Pizzadeeg).';

  @override
  String get faqAddSublinkedStep5Title => 'Sla je wijzigingen op';

  @override
  String get faqAddSublinkedStep5Desc => 'Tik op het opslaanpictogram om het gekoppelde recept te bewaren.';

  @override
  String get faqAddSublinkedStep6Title => 'Klaar!';

  @override
  String get faqAddSublinkedStep6Desc => 'Het gekoppelde recept verschijnt nu in je recept, klaar om op te tikken en te bekijken.';

  @override
  String get faqWhatAreHeadersTitle => 'Wat zijn koppen?';

  @override
  String get faqWhatAreHeadersSubtitle => 'Organiseer recepten in secties';

  @override
  String get faqWhatAreHeadersAnswer => 'Met koppen kun je je receptingrediënten en -stappen in secties verdelen. Zo kun je bijvoorbeeld aparte secties hebben voor \'Saus\', \'Deeg\' en \'Beleg\' in een pizzarecept. Ze maken lange recepten veel gemakkelijker te volgen.';

  @override
  String get faqWhatAreSublinkedTitle => 'Wat zijn gekoppelde recepten?';

  @override
  String get faqWhatAreSublinkedSubtitle => 'Verbind gerelateerde recepten met elkaar';

  @override
  String get faqWhatAreSublinkedAnswer => 'Gekoppelde recepten laten je gerelateerde recepten aan elkaar verbinden. Zo kan een Margherita Pizza-recept bijvoorbeeld linken naar je Pizzadeeg-recept. Bij het bekijken van het hoofdrecept kun je op het gekoppelde recept tikken om er direct naartoe te gaan — geen zoeken nodig.';

  @override
  String get faqMacroCalcTitle => 'Hoe gebruik je de Macro Calculator';

  @override
  String get faqMacroCalcSubtitle => 'Bereken automatisch calorieën en macro\'s voor elk recept';

  @override
  String get faqMacroCalcStep1Title => 'Open een recept';

  @override
  String get faqMacroCalcStep1Desc => 'Open een recept en scroll naar het gedeelte Voedingswaarden.';

  @override
  String get faqMacroCalcStep2Title => 'Tik om te berekenen';

  @override
  String get faqMacroCalcStep2Desc => 'Tik op het lege voedingswaardengedeelte om de calculator te openen. Er staat \'Tik om te berekenen\'.';

  @override
  String get faqMacroCalcStep3Title => 'Automatische analyse';

  @override
  String get faqMacroCalcStep3Desc => 'De calculator koppelt je ingrediënten automatisch aan de USDA-voedingsdatabase en berekent calorieën, eiwitten, koolhydraten, vetten en meer.';

  @override
  String get faqMacroCalcStep4Title => 'Handmatig invoeren';

  @override
  String get faqMacroCalcStep4Desc => 'Tik op \'Handmatig invoeren\' om de voedingswaarden zelf te bewerken.';

  @override
  String get faqMacroCalcStep5Title => 'Ingrediëntmatches bekijken';

  @override
  String get faqMacroCalcStep5Desc => 'Scroll naar beneden om te zien hoe elk ingrediënt is gekoppeld aan een USDA-voedingsmiddel. Gekoppelde recepten gebruiken hun eigen voedingsgegevens.';

  @override
  String get faqMacroCalcStep5Tip => 'Wat zijn gekoppelde recepten? Bekijk het onderdeel \'Wat zijn gekoppelde recepten?\' in de FAQ!';

  @override
  String get faqMacroCalcStep6Title => 'USDA-database doorzoeken';

  @override
  String get faqMacroCalcStep6Desc => 'Tik op een ingrediënt om in de USDA-database naar een betere match te zoeken.';

  @override
  String get faqMacroCalcStep7Title => 'Voeding gekoppelde recepten';

  @override
  String get faqMacroCalcStep7Desc => 'Ingrediënten die aan een ander recept zijn gekoppeld, tonen de voedingsgegevens van dat recept. Je kunt de schaal aanpassen.';

  @override
  String get faqMacroCalcStep8Title => 'Sla je resultaten op';

  @override
  String get faqMacroCalcStep8Desc => 'Tik op Opslaan om de voedingsgegevens op te slaan. De macro\'s verschijnen bij je recept met grafieken en details per portie.';

  @override
  String get faqMacroCalcStep9Title => 'Weergave aanpassen';

  @override
  String get faqMacroCalcStep9Desc => 'Via Instellingen > Voedingsweergave kun je kiezen welke voedingsstoffen je wilt tonen en hoe de grafieken eruitzien.';

  @override
  String get faqWhatIsMacroCalcTitle => 'Wat is de Macro Calculator?';

  @override
  String get faqWhatIsMacroCalcSubtitle => 'Automatische voedingsschatting voor recepten';

  @override
  String get faqWhatIsMacroCalcAnswer => 'De Macro Calculator schat automatisch de voedingswaarde van je recepten door elk ingrediënt te koppelen aan de USDA-voedingsdatabase. Het berekent calorieën, eiwitten, koolhydraten, vetten, vezels, suiker, natrium en meer — alles per portie. Je vindt het in het gedeelte Voedingswaarden van elk recept.';

  @override
  String get faqImportFailedTitle => 'Waarom is mijn import mislukt?';

  @override
  String get faqImportFailedSubtitle => 'Veelvoorkomende oorzaken en oplossingen';

  @override
  String get faqImportFailedAnswer => 'Imports kunnen om verschillende redenen mislukken:\n\n• De website blokkeert mogelijk geautomatiseerde toegang — probeer de recepttekst te kopiëren en gebruik in plaats daarvan Tekstimport.\n• De link is mogelijk verlopen of privé — zorg ervoor dat het een openbare link is.\n• Sommige sites gebruiken formaten die moeilijker te verwerken zijn — probeer de AI-import als alternatief.\n• Controleer je internetverbinding en probeer het opnieuw.';

  @override
  String get faqDeviceTransferTitle => 'Kan ik importeren vanaf andere apparaten?';

  @override
  String get faqDeviceTransferSubtitle => 'Draag recepten over tussen telefoons en tablets';

  @override
  String get faqDeviceTransferAnswer => 'Ja! Gebruik de functie Apparaatoverdracht in Instellingen > Gegevens > Apparaatoverdracht. Genereer een code op je oude apparaat en voer deze in op je nieuwe. Al je recepten, kookboeken en afbeeldingen worden overgedragen.';

  @override
  String get themeFrost => 'Vorst';

  @override
  String get themeEmber => 'Gloed';

  @override
  String get themeSpring => 'Lente';

  @override
  String get themeAlchemist => 'Alchemist';

  @override
  String get themeMatcha => 'Matcha';

  @override
  String get themeCustom => 'Aangepast';

  @override
  String get communitySortTopRated => 'Best beoordeeld';

  @override
  String get communityHasImages => 'Met afbeeldingen';

  @override
  String get communityListView => 'Lijstweergave';

  @override
  String get communityGridView => 'Rasterweergave';

  @override
  String get communityDownloadOptions => 'Downloadopties';

  @override
  String communityDownloadWithImages(String size) {
    return 'Met afbeeldingen ($size)';
  }

  @override
  String communityDownloadImagesIncluded(int count) {
    return '$count afbeeldingen inbegrepen';
  }

  @override
  String get communityDownloadTextOnly => 'Alleen tekst';

  @override
  String get communityDownloadTextOnlySubtitle => 'Snellere download, geen afbeeldingen';

  @override
  String get communityTapToPreview => 'Tik op een recept voor een voorbeeld';

  @override
  String communityImageCountLabel(int count) {
    return '$count afbeeldingen';
  }

  @override
  String get communityYourRating => 'Jouw beoordeling:';

  @override
  String get communityRateThis => 'Beoordeel dit kookboek:';

  @override
  String communityDownloadingImages(int current, int total) {
    return 'Afbeeldingen downloaden... $current/$total';
  }

  @override
  String get communityViewFullRecipe => 'Volledig recept bekijken';

  @override
  String communityMoreIngredients(int count) {
    return '+ $count meer';
  }

  @override
  String communityStepCount(int count) {
    return '$count stappen';
  }

  @override
  String get communityNotes => 'Notities';

  @override
  String get communityStatPrep => 'Voorbereiding';

  @override
  String get communityStatCook => 'Koken';

  @override
  String get communityStatTotal => 'Totaal';

  @override
  String get communityStatServings => 'Porties';

  @override
  String communityStepDuration(int minutes) {
    return '$minutes min';
  }

  @override
  String get communityEditPublication => 'Publicatie bewerken';

  @override
  String get communityEditDescription => 'Beschrijving';

  @override
  String get communityEditDescriptionHint => 'Vertel mensen over dit kookboek...';

  @override
  String get communityEditTags => 'Tags';

  @override
  String get communityEditSuccess => 'Publicatie bijgewerkt!';

  @override
  String get communityEditFailed => 'Bijwerken van publicatie mislukt';

  @override
  String get communityNoRatingsYet => 'Nog geen beoordelingen';

  @override
  String get communityStatusPublished => 'Gepubliceerd';

  @override
  String get communityStatusUnderReview => 'Wordt beoordeeld';

  @override
  String get communityStatusRemoved => 'Verwijderd';

  @override
  String get communityUnderReview => 'Dit kookboek wordt beoordeeld door ons moderatieteam.';

  @override
  String get communityPublishPreparing => 'Kookboek voorbereiden...';

  @override
  String communityPublishUploading(int current, int total) {
    return 'Afbeeldingen uploaden ($current/$total)';
  }

  @override
  String get communityPublishPublishing => 'Publiceren naar community...';

  @override
  String get communityPublishBackground => 'Je kunt dit scherm verlaten – het publiceren gaat door op de achtergrond.';

  @override
  String get communityPublishDone => 'Gepubliceerd!';

  @override
  String communityPublishImagesSkipped(int count) {
    return '$count afbeeldingen zijn overgeslagen (afgewezen door moderatie)';
  }

  @override
  String communityPublishRejected(int count) {
    return '$count afgewezen door moderatie';
  }

  @override
  String get communityConfigurePublication => 'Publicatie configureren';

  @override
  String get communityPublishTitle => 'Titel';

  @override
  String get communityPublishTitleHint => 'Kookboektitel';

  @override
  String get communityPublishDescription => 'Beschrijving';

  @override
  String get communityPublishDescriptionHint => 'Vertel mensen over dit kookboek...';

  @override
  String get communityPublishTags => 'Tags';

  @override
  String get communityPublishIncludeImages => 'Afbeeldingen toevoegen';

  @override
  String get communityPublishIncludeImagesSubtitle => 'Upload receptafbeeldingen bij dit kookboek. Afbeeldingen worden gecontroleerd op veiligheid.';

  @override
  String get communityPublishSummary => 'Samenvatting';

  @override
  String communityPublishRecipesSummary(int count) {
    return '$count recepten';
  }

  @override
  String get communityPublishImagesWillUpload => 'Afbeeldingen worden geüpload';

  @override
  String get communityPublishTextOnlyNoImages => 'Alleen tekst (geen afbeeldingen)';

  @override
  String get communityPublishTryAgain => 'Opnieuw proberen';

  @override
  String communityPublishUploadInProgress(int current, int total) {
    return 'Publicatie bezig... ($current/$total afbeeldingen)';
  }

  @override
  String get surpriseMeTitle => 'Verras me!';

  @override
  String get surpriseMeSubtitle => 'Wat zal ik koken?';

  @override
  String get hintNutritionCalculator => 'Wist je dat? Tik op het voedingsicoon om automatisch de voedingswaarden van elk recept te berekenen.';

  @override
  String get hintCookingScreen => 'Probeer de kookmodus! Tik op \'Koken\' bij een recept voor handsfree stap-voor-stap instructies.';

  @override
  String get hintIngredientHeaders => 'Tip: Typ een regel die eindigt met \':\' bij de ingrediënten om een sectiekop te maken.';

  @override
  String get hintImportMethods => 'Importeer recepten van URL\'s, foto\'s, PDF\'s of zelfs Instagram en TikTok!';

  @override
  String get hintMealPlanAutoFill => 'Sleep recepten naar je maaltijdplanner, of tik op een dag om uit je collectie te kiezen.';

  @override
  String get hintRecipeScaling => 'Tik op het aantal porties bij een recept om de ingrediënten aan te passen.';

  @override
  String get hintShoppingListGen => 'Voeg receptingrediënten met één tik toe aan je boodschappenlijst.';

  @override
  String get hintRecipeNotes => 'Voeg persoonlijke notities toe aan elk recept — tips, aanpassingen of herinneringen.';

  @override
  String get hintCookbookOrganization => 'Maak meerdere kookboeken om je recepten te ordenen op thema of gelegenheid.';

  @override
  String get hintTagSystem => 'Tag recepten voor eenvoudig filteren — maak aangepaste tags zoals \'Snel\', \'Favoriet\', enz.';

  @override
  String get allergyMyAllergies => 'Mijn Allergieën';

  @override
  String get allergyDisabledTab => 'Uitgeschakeld';

  @override
  String get allergyNoDisabledTitle => 'Geen uitgeschakelde waarschuwingen';

  @override
  String get allergyNoDisabledSubtitle => 'Wanneer je allergiewaarschuwingen bij recepten uitschakelt, verschijnen ze hier zodat je ze kunt herstellen.';

  @override
  String get allergyDisabledInfo => 'Deze recepten hebben allergiewaarschuwingen uitgeschakeld. Tik om te herstellen.';

  @override
  String trashRestoredMessage(String title) {
    return '\"$title\" hersteld';
  }

  @override
  String get nutrientCalories => 'Calorieën';

  @override
  String get nutrientTotalFat => 'Totaal vet';

  @override
  String get nutrientSaturatedFat => 'Verzadigd vet';

  @override
  String get nutrientTransFat => 'Transvet';

  @override
  String get nutrientMonounsaturatedFat => 'Enkelvoudig onverzadigd vet';

  @override
  String get nutrientPolyunsaturatedFat => 'Meervoudig onverzadigd vet';

  @override
  String get nutrientCarbohydrates => 'Koolhydraten';

  @override
  String get nutrientFiber => 'Voedingsvezel';

  @override
  String get nutrientSugars => 'Suikers';

  @override
  String get nutrientProtein => 'Eiwitten';

  @override
  String get nutrientCholesterol => 'Cholesterol';

  @override
  String get nutrientSodium => 'Natrium';

  @override
  String get nutrientPotassium => 'Kalium';

  @override
  String get nutrientCalcium => 'Calcium';

  @override
  String get nutrientIron => 'IJzer';

  @override
  String get nutrientMagnesium => 'Magnesium';

  @override
  String get nutrientPhosphorus => 'Fosfor';

  @override
  String get nutrientZinc => 'Zink';

  @override
  String get nutrientCopper => 'Koper';

  @override
  String get nutrientManganese => 'Mangaan';

  @override
  String get nutrientSelenium => 'Selenium';

  @override
  String get nutrientVitaminA => 'Vitamine A';

  @override
  String get nutrientVitaminC => 'Vitamine C';

  @override
  String get nutrientVitaminD => 'Vitamine D';

  @override
  String get nutrientVitaminE => 'Vitamine E';

  @override
  String get nutrientVitaminK => 'Vitamine K';

  @override
  String get nutrientThiaminB1 => 'Thiamine (B1)';

  @override
  String get nutrientRiboflavinB2 => 'Riboflavine (B2)';

  @override
  String get nutrientNiacinB3 => 'Niacine (B3)';

  @override
  String get nutrientPantothenicAcidB5 => 'Pantotheenzuur (B5)';

  @override
  String get nutrientVitaminB6 => 'Vitamine B6';

  @override
  String get nutrientVitaminB12 => 'Vitamine B12';

  @override
  String get nutrientFolate => 'Foliumzuur';

  @override
  String get nutrientCholine => 'Choline';

  @override
  String get nutrientCategoryMacronutrients => 'Macronutriënten';

  @override
  String get nutrientCategoryMinerals => 'Mineralen';

  @override
  String get nutrientCategoryVitamins => 'Vitaminen';

  @override
  String get nutrientCarbs => 'Koolhydraten';

  @override
  String get nutrientFat => 'Vet';

  @override
  String nutritionKcalPerServing(int count) {
    return '$count kcal/portie';
  }

  @override
  String nutritionKcalTotal(int count) {
    return '$count kcal totaal';
  }

  @override
  String get shareShoppingList => 'Boodschappenlijst delen';

  @override
  String get shareOneTimeLink => 'Eenmalige link';

  @override
  String get shareOneTimeLinkSubtitle => 'Gratis • 24 uur geldig • Alleen bekijken/downloaden';

  @override
  String get shareGenerateLink => 'Link genereren';

  @override
  String get shareFamilyShare => 'Gezinsdeling';

  @override
  String get shareFamilySyncSubtitle => 'Realtime synchronisatie · Rechten per lid';

  @override
  String get shareFamilyCreateJoin => 'Maak een gezin aan of sluit je aan om te delen';

  @override
  String get shareFamilyRequiresCloudSync => 'Vereist Cloud Sync-abonnement';

  @override
  String get shareFamilyUpgradeMessage => 'Upgrade naar Cloud Sync om kookboeken en lijsten in realtime met je gezin te delen.';

  @override
  String get shareFamilySignIn => 'Log in om gezinsdeling te gebruiken';

  @override
  String get shareFamilySetupInSettings => 'Maak een gezin aan of sluit je aan in Instellingen → Gezinsdeling';

  @override
  String get shareSharedWith => 'Gedeeld met';

  @override
  String get shareRevoked => 'Deling ingetrokken';

  @override
  String get shareSignInRequired => 'Log in om deellinks te maken';

  @override
  String get shareCreateFailed => 'Link aanmaken mislukt';

  @override
  String get shareNoFamilyMembers => 'Geen andere gezinsleden om mee te delen';

  @override
  String get shareAddFamilyMembers => 'Gezinsleden toevoegen';

  @override
  String get shareWith => 'Delen met';

  @override
  String shareSharedWithMember(String name) {
    return 'Gedeeld met $name';
  }

  @override
  String get shareShareFailed => 'Delen mislukt';

  @override
  String get shareLinkCopied => 'Link gekopieerd!';

  @override
  String shareLinkExpiresIn(int hours) {
    return 'Verloopt over $hours uur';
  }

  @override
  String get shareRevoke => 'Intrekken';

  @override
  String get shareUpgrade => 'Upgraden';

  @override
  String get sharePermReadOnly => 'Alleen lezen';

  @override
  String get sharePermAddOnly => 'Alleen toevoegen';

  @override
  String get sharePermFullEdit => 'Volledig bewerken';

  @override
  String get sharePermFullAccess => 'Volledige toegang';

  @override
  String get sharePermViewRecipes => 'Kan recepten bekijken';

  @override
  String get sharePermAddRecipes => 'Kan nieuwe recepten toevoegen';

  @override
  String get sharePermEditRecipes => 'Kan elk recept bewerken';

  @override
  String get sharePermViewItems => 'Kan items bekijken';

  @override
  String get sharePermAddItems => 'Kan items toevoegen, eigen items bewerken';

  @override
  String get sharePermEditItems => 'Kan items bewerken en verwijderen';

  @override
  String get shareUnknownMember => 'Onbekend';

  @override
  String get subscriptionTitle => 'Abonnement';

  @override
  String get subscriptionUpgradeToPro => 'Upgraden naar Pro';

  @override
  String get subscriptionUnlockFeatures => 'Ontgrendel cloudsynchronisatie, slim importeren en meer.';

  @override
  String get subscriptionViewPlans => 'Abonnementen bekijken';

  @override
  String get subscriptionRestored => 'Aankopen succesvol hersteld!';

  @override
  String get subscriptionNoPurchases => 'Geen eerdere aankopen gevonden.';

  @override
  String subscriptionRestoreFailed(String error) {
    return 'Herstel mislukt: $error';
  }

  @override
  String get subscriptionRestorePurchases => 'Aankopen herstellen';

  @override
  String subscriptionCancelledUntil(String date) {
    return 'Geannuleerd — toegang tot $date';
  }

  @override
  String get subscriptionRenews => 'Verlengt op';

  @override
  String get subscriptionPlan => 'Abonnement';

  @override
  String get subscriptionLifetime => 'Levenslang — verloopt nooit';

  @override
  String get subscriptionManage => 'Abonnement beheren';

  @override
  String get subscriptionUnknownDate => 'Onbekend';

  @override
  String get subscriptionUpgradeToUnlock => 'Upgrade naar Pro om te ontgrendelen';

  @override
  String get subscriptionProBadge => 'PRO';

  @override
  String get customThemeTitle => 'Aangepast thema';

  @override
  String get customThemeColors => 'Kleuren';

  @override
  String get customThemeBackground => 'Achtergrond';

  @override
  String get customThemeBackgroundDesc => 'App-achtergrond, scaffold';

  @override
  String get customThemePrimary => 'Primair';

  @override
  String get customThemePrimaryDesc => 'Knoppen, accenten, app-balk';

  @override
  String get customThemeAccent => 'Accent';

  @override
  String get customThemeAccentDesc => 'FAB, schakelaars, secundaire accenten';

  @override
  String get customThemeStartFromPreset => 'Begin vanuit een preset';

  @override
  String get customThemeLightMode => 'Licht';

  @override
  String get customThemeDarkMode => 'Donker';

  @override
  String customThemeLinkedOverlay(String mode) {
    return 'Kleuren worden automatisch gegenereerd op basis van je $mode thema';
  }

  @override
  String get customThemeUnlockButton => 'Kleuren aanpassen';

  @override
  String customThemeLinkButton(String mode) {
    return 'Koppelen aan $mode';
  }

  @override
  String get customThemeLivePreview => 'Live voorbeeld';

  @override
  String get settingsUserFallback => 'Gebruiker';

  @override
  String get settingsManageSection => 'Beheren';

  @override
  String get settingsExportNone => 'Niets geselecteerd';

  @override
  String get settingsExportPartial => 'Gedeeltelijke back-up';

  @override
  String get settingsSystemLanguage => 'Systeem';

  @override
  String get tierFamily => 'FAMILY';

  @override
  String get tierCreator => 'CREATOR';

  @override
  String get tierFreeName => 'Gratis';

  @override
  String get tierPremiumName => 'Premium';

  @override
  String get tierCloudSyncName => 'Cloud Sync';

  @override
  String get tierCloudSyncFamilyName => 'Cloud Sync Gezin';

  @override
  String get tierCreatorName => 'Creator';

  @override
  String get nutritionEstimated => 'Geschatte waarden';

  @override
  String get nutritionTipMatch => 'Tik op een ingrediënt om de USDA-match te wijzigen';

  @override
  String get nutritionTipManual => 'Voer exacte voedingswaarden in als je die kent';

  @override
  String get nutritionTipSpecific => 'Kies specifieke types (bijv. \"tarwebloem\" in plaats van alleen \"bloem\")';

  @override
  String get nutritionTipSaved => 'Je correcties worden opgeslagen voor toekomstige recepten';

  @override
  String get nutritionGotIt => 'Begrepen';

  @override
  String get nutritionScaleMultiplier => 'Schaalfactor';

  @override
  String get nutritionScaleHelper => '1,0 = volledig recept';

  @override
  String nutritionOpenRecipe(String title) {
    return '$title openen';
  }

  @override
  String get nutrientCal => 'Cal';

  @override
  String get nutrientSugar => 'Suiker';

  @override
  String get appearanceCustomThemeRequiresPremium => 'Aangepast thema vereist Premium';

  @override
  String get appearancePremiumBadge => 'Premium';

  @override
  String get substitutionsAll => 'Alle';

  @override
  String substitutionsCount(int count, String category) {
    return '$count vervangers • $category';
  }

  @override
  String get colorPickerTitle => 'Kies een kleur';

  @override
  String get colorPickerHex => 'Hex';

  @override
  String get colorPickerSelect => 'Selecteer';

  @override
  String get scanSelectPages => 'Meerdere pagina\'s selecteren';

  @override
  String get scanNoTextPdf => 'Geen tekst gevonden in PDF. Probeer een duidelijkere scan of de optie Tekst plakken.';

  @override
  String scanLittleTextPdf(int count) {
    return 'Heel weinig tekst gedetecteerd in PDF ($count tekens). De scan is mogelijk te wazig. Probeer een PDF van betere kwaliteit of gebruik de optie Tekst plakken.';
  }

  @override
  String get scanNoTextImage => 'Geen tekst gevonden in afbeelding. Probeer de foto bij betere verlichting te nemen of gebruik de optie Tekst plakken.';

  @override
  String scanLittleTextImage(int count) {
    return 'Heel weinig tekst gedetecteerd ($count tekens). Probeer een duidelijkere foto met betere verlichting, of gebruik de optie Tekst plakken.';
  }

  @override
  String scanProgress(int current, int total) {
    return 'Pagina $current van $total scannen...';
  }

  @override
  String get communityTagHint => 'Aangepaste tag toevoegen...';

  @override
  String get tagPickerOrganize => 'Tags helpen je om je recepten te organiseren';

  @override
  String get tagPickerLoadDefaults => 'Standaardtags laden';

  @override
  String get tagPickerExampleHint => 'bijv. Date Night';

  @override
  String drawerProTier(String tier) {
    return 'Pro · $tier';
  }

  @override
  String get accountStoreFallback => 'Winkel';

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
}
