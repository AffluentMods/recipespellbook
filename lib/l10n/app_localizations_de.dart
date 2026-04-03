// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Rezept-Zauberbuch';

  @override
  String get navHome => 'Startseite';

  @override
  String get navCookbooks => 'Kochbücher';

  @override
  String get navPlanner => 'Planer';

  @override
  String get navShopping => 'Einkauf';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get homeGreeting => 'Willkommen zurück!';

  @override
  String get homeQuickAccess => 'Schnellzugriff';

  @override
  String get homeMealPlan => 'Heutige Mahlzeiten';

  @override
  String get homePinnedRecipes => 'Angeheftete Rezepte';

  @override
  String get homeRecentRecipes => 'Kürzlich angesehen';

  @override
  String get homeNoMealsPlanned => 'Keine Mahlzeiten für heute geplant';

  @override
  String get homeNoPinnedRecipes => 'Noch keine angehefteten Rezepte';

  @override
  String get homeNoRecentRecipes => 'Keine kürzlich angesehenen Rezepte';

  @override
  String get recipesTitle => 'Rezepte';

  @override
  String get recipesEmpty => 'Noch keine Rezepte';

  @override
  String get recipesEmptySubtitle => 'Füge dein erstes Rezept hinzu, um zu beginnen';

  @override
  String get recipeAdd => 'Rezept hinzufügen';

  @override
  String get recipeEdit => 'Rezept bearbeiten';

  @override
  String get recipeDelete => 'Rezept löschen';

  @override
  String get recipeDeleteConfirm => 'Bist du sicher, dass du dieses Rezept löschen möchtest?';

  @override
  String get recipeFavorite => 'Zu Favoriten hinzufügen';

  @override
  String get recipeUnfavorite => 'Aus Favoriten entfernen';

  @override
  String get recipePin => 'Rezept anheften';

  @override
  String get recipeUnpin => 'Rezept lösen';

  @override
  String get recipeShare => 'Rezept teilen';

  @override
  String get recipePrint => 'Rezept drucken';

  @override
  String get recipeDuplicate => 'Rezept duplizieren';

  @override
  String get recipeAddToMealPlan => 'Zum Mahlzeitenplan hinzufügen';

  @override
  String get recipeAddToShoppingList => 'Zur Einkaufsliste hinzufügen';

  @override
  String get recipeStartCooking => 'Kochen starten';

  @override
  String get recipeFieldTitle => 'Titel';

  @override
  String get recipeFieldDescription => 'Beschreibung';

  @override
  String get recipeFieldIngredients => 'Zutaten';

  @override
  String get recipeFieldInstructions => 'Anleitung';

  @override
  String get recipeFieldNotes => 'Notizen';

  @override
  String get notesTitle => 'Notizen';

  @override
  String get recipeFieldServings => 'Portionen';

  @override
  String get recipeFieldPrepTime => 'Vorbereitungszeit';

  @override
  String get recipeFieldCookTime => 'Kochzeit';

  @override
  String get recipeFieldTotalTime => 'Gesamtzeit';

  @override
  String get recipeFieldSource => 'Quelle';

  @override
  String get recipeFieldCourse => 'Gang';

  @override
  String get recipeFieldCategory => 'Kategorie';

  @override
  String get recipeFieldTags => 'Tags';

  @override
  String get recipeFieldRating => 'Bewertung';

  @override
  String get ratingCommon => 'Gewöhnlich';

  @override
  String get ratingUncommon => 'Ungewöhnlich';

  @override
  String get ratingRare => 'Selten';

  @override
  String get ratingEpic => 'Episch';

  @override
  String get ratingLegendary => 'Legendär';

  @override
  String get ratingUnrated => 'Nicht bewertet';

  @override
  String get minutesAbbrev => 'Min';

  @override
  String get hoursAbbrev => 'Std';

  @override
  String get servingsUnit => 'Portionen';

  @override
  String get ingredientsTitle => 'Zutaten';

  @override
  String get ingredientsEmpty => 'Keine Zutaten hinzugefügt';

  @override
  String get ingredientAdd => 'Zutat hinzufügen';

  @override
  String get ingredientPlaceholder => 'z.B., 2 Tassen Mehl';

  @override
  String get instructionsTitle => 'Anleitung';

  @override
  String get instructionsEmpty => 'Keine Anleitung hinzugefügt';

  @override
  String get instructionAdd => 'Schritt hinzufügen';

  @override
  String get instructionPlaceholder => 'Beschreibe diesen Schritt...';

  @override
  String stepNumber(int number) {
    return 'Schritt $number';
  }

  @override
  String get cookbooksTitle => 'Kochbücher';

  @override
  String get cookbooksEmpty => 'Noch keine Kochbücher';

  @override
  String get cookbookAdd => 'Neues Kochbuch';

  @override
  String get cookbookEdit => 'Kochbuch Bearbeiten';

  @override
  String get cookbookDelete => 'Kochbuch löschen';

  @override
  String get cookbookDeleteConfirm => 'Dieses Kochbuch und alle seine Rezepte löschen?';

  @override
  String cookbookRecipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Rezepte',
      one: '1 Rezept',
      zero: 'Keine Rezepte',
    );
    return '$_temp0';
  }

  @override
  String get shoppingDeli => 'Feinkost';

  @override
  String get shoppingCannedGoods => 'Konserven & Suppen';

  @override
  String get shoppingCondiments => 'Gewürze & Saucen';

  @override
  String get shoppingGrainsAndPasta => 'Getreide, Pasta & Reis';

  @override
  String get shoppingCookingAndBaking => 'Kochen & Backen';

  @override
  String get shoppingBreakfastCereal => 'Frühstück & Müsli';

  @override
  String get shoppingBeerWineSpirits => 'Bier, Wein & Spirituosen';

  @override
  String get shoppingBaby => 'Baby';

  @override
  String get shoppingPet => 'Haustier';

  @override
  String get shoppingHousehold => 'Haushalt';

  @override
  String get shoppingPersonalCare => 'Körperpflege';

  @override
  String get plannerTitle => 'Mahlzeitenplaner';

  @override
  String get plannerEmpty => 'Keine Mahlzeiten geplant';

  @override
  String get plannerEmptySubtitle => 'Tippe auf + um eine Mahlzeit hinzuzufügen';

  @override
  String get plannerAddMeal => 'Mahlzeit Hinzufügen';

  @override
  String get plannerToday => 'Heute';

  @override
  String get plannerThisWeek => 'Diese Woche';

  @override
  String get plannerBreakfast => 'Frühstück';

  @override
  String get plannerLunch => 'Mittagessen';

  @override
  String get plannerDinner => 'Abendessen';

  @override
  String get plannerSnack => 'Snack';

  @override
  String get shoppingTitle => 'Einkaufsliste';

  @override
  String get shoppingEmpty => 'Deine Liste ist leer';

  @override
  String get shoppingEmptySubtitle => 'Füge Artikel hinzu oder importiere aus Rezepten';

  @override
  String get shoppingAddItem => 'Artikel hinzufügen...';

  @override
  String get shoppingCheckedItems => 'Abgehakte Artikel';

  @override
  String get shoppingClearChecked => 'Markierte löschen';

  @override
  String get shoppingClearAll => 'Alle löschen';

  @override
  String get shoppingCategories => 'Einkaufskategorien';

  @override
  String get shoppingUncategorized => 'Ohne Kategorie';

  @override
  String shoppingItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Artikel',
      one: '1 Artikel',
      zero: 'Keine Artikel',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsAppearance => 'Erscheinungsbild';

  @override
  String get settingsTheme => 'Design';

  @override
  String get settingsThemeMode => 'Design-Modus';

  @override
  String get settingsThemeModeSystem => 'System';

  @override
  String get settingsThemeModeLight => 'Hell';

  @override
  String get settingsThemeModeDark => 'Dunkel';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsMeasurements => 'Maßeinheiten';

  @override
  String get settingsMeasurementsUS => 'US (Tassen, oz)';

  @override
  String get settingsMeasurementsMetric => 'Metrisch (ml, g)';

  @override
  String get settingsKitchenBuddy => 'RPG-Modus';

  @override
  String get settingsKitchenBuddySubtitle => 'Fantasy-Texte und -Bilder aktivieren';

  @override
  String get settingsRecipes => 'Rezepte';

  @override
  String get settingsManageCourses => 'Gänge verwalten';

  @override
  String get settingsManageCategories => 'Kategorien verwalten';

  @override
  String get settingsManageTags => 'Tags verwalten';

  @override
  String get settingsData => 'Daten';

  @override
  String get settingsExport => 'Daten exportieren';

  @override
  String get settingsExportSubtitle => 'Sichere deine Rezepte';

  @override
  String get settingsImport => 'Daten importieren';

  @override
  String get settingsImportSubtitle => 'Aus Backup wiederherstellen';

  @override
  String get settingsImportFromApps => 'Aus anderen Apps importieren';

  @override
  String get settingsImportFromAppsSubtitle => 'Paprika, Crouton, Mela & mehr';

  @override
  String get settingsAbout => 'Über';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsPrivacy => 'Datenschutzrichtlinie';

  @override
  String get settingsTerms => 'Nutzungsbedingungen';

  @override
  String get settingsFeedback => 'Feedback senden';

  @override
  String get importTitle => 'Importieren';

  @override
  String get importCreate => 'Erstellen';

  @override
  String get importCreateSubtitle => 'Schreibe dein eigenes Rezept';

  @override
  String get importSubtitle => 'Von URL, Bild oder Datei';

  @override
  String get importChooseMethod => 'Wie möchtest du dein Rezept hinzufügen?';

  @override
  String get importProgress => 'Rezept wird importiert...';

  @override
  String get importFromURL => 'Von URL';

  @override
  String get importFromImage => 'Von Bild';

  @override
  String get importFromFile => 'Von Datei';

  @override
  String get importFromText => 'Aus Text Importieren';

  @override
  String get importProcessing => 'Wird verarbeitet...';

  @override
  String get importSuccess => 'Rezept erfolgreich importiert';

  @override
  String get importError => 'Rezept konnte nicht importiert werden';

  @override
  String get importBulkTitle => 'Rezepte importieren';

  @override
  String importBulkFound(int count) {
    return '$count Rezepte gefunden';
  }

  @override
  String get importBulkImportAll => 'Alle importieren';

  @override
  String get importBulkImportFirst => 'Erstes importieren';

  @override
  String get searchTitle => 'Suchen';

  @override
  String get searchHint => 'Rezepte suchen...';

  @override
  String get searchNoResults => 'Keine Rezepte gefunden';

  @override
  String get searchFilters => 'Filter';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionEdit => 'Bearbeiten';

  @override
  String get actionAdd => 'Hinzufügen';

  @override
  String get actionDone => 'Fertig';

  @override
  String get actionClose => 'Schließen';

  @override
  String get actionConfirm => 'Bestätigen';

  @override
  String get actionUndo => 'Rückgängig';

  @override
  String get actionRetry => 'Wiederholen';

  @override
  String get actionCopy => 'Kopieren';

  @override
  String get actionPaste => 'Einfügen';

  @override
  String get actionOk => 'OK';

  @override
  String get actionShare => 'Teilen';

  @override
  String get actionClear => 'Leeren';

  @override
  String get errorGeneric => 'Etwas ist schiefgelaufen';

  @override
  String get errorNetwork => 'Netzwerkfehler. Bitte überprüfe deine Verbindung.';

  @override
  String get errorNotFound => 'Nicht gefunden';

  @override
  String get errorInvalidURL => 'Ungültige URL';

  @override
  String get successSaved => 'Erfolgreich gespeichert';

  @override
  String get successDeleted => 'Erfolgreich gelöscht';

  @override
  String get successCopied => 'In die Zwischenablage kopiert';

  @override
  String get confirmDeleteTitle => 'Löschen bestätigen';

  @override
  String get confirmDeleteMessage => 'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get emptyStateTitle => 'Noch nichts hier';

  @override
  String get emptyStateSubtitle => 'Beginne mit dem Hinzufügen deines ersten Elements';

  @override
  String get dateToday => 'Heute';

  @override
  String get dateYesterday => 'Gestern';

  @override
  String get dateTomorrow => 'Morgen';

  @override
  String timeMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Minuten',
      one: 'Minute',
    );
    return '$count $_temp0';
  }

  @override
  String timeHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Stunden',
      one: 'Stunde',
    );
    return '$count $_temp0';
  }

  @override
  String get trashTitle => 'Papierkorb';

  @override
  String get trashEmpty => 'Papierkorb ist leer';

  @override
  String get trashEmptySubtitle => 'Gelöschte Rezepte erscheinen hier für 30 Tage';

  @override
  String get trashRestore => 'Wiederherstellen';

  @override
  String get trashRestored => 'wiederhergestellt';

  @override
  String get trashDeletePermanently => 'Endgültig löschen';

  @override
  String get trashEmptyTrash => 'Papierkorb leeren';

  @override
  String get trashEmptyConfirm => 'Dies löscht alle Rezepte im Papierkorb endgültig. Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get trashEmptied => 'Papierkorb geleert';

  @override
  String get trashDeleted => 'Gelöscht';

  @override
  String get trashDeletedToday => 'Heute gelöscht';

  @override
  String get trashDeletedYesterday => 'Gestern gelöscht';

  @override
  String trashDeletedDaysAgo(int days) {
    return 'Vor $days Tagen gelöscht';
  }

  @override
  String get trashExpiresToday => 'Läuft heute ab';

  @override
  String trashDaysLeft(int days) {
    return '$days Tage übrig';
  }

  @override
  String get cookingModeTitle => 'Kochmodus';

  @override
  String get cookingSetTimer => 'Timer Einstellen';

  @override
  String get cookingTimerDone => 'Timer Fertig!';

  @override
  String get cookingTimerFinished => 'Dein Timer ist abgelaufen.';

  @override
  String get cookingExitTitle => 'Kochmodus verlassen?';

  @override
  String get cookingExitMessage => 'Dein Fortschritt geht verloren.';

  @override
  String get cookingExit => 'Verlassen';

  @override
  String get cookingFinish => 'Fertig';

  @override
  String get taxonomyAddCourse => 'Gang Hinzufügen';

  @override
  String get taxonomyEditCourse => 'Gang Bearbeiten';

  @override
  String get taxonomyDeleteCourse => 'Gang Löschen?';

  @override
  String get taxonomyAddCategory => 'Kategorie Hinzufügen';

  @override
  String get taxonomyEditCategory => 'Kategorie Bearbeiten';

  @override
  String get taxonomyDeleteCategory => 'Kategorie Löschen?';

  @override
  String get taxonomyBuiltIn => 'Eingebaut';

  @override
  String get taxonomyCustom => 'Benutzerdefiniert';

  @override
  String get taxonomyRestoreDefaults => 'Standards Wiederherstellen';

  @override
  String get taxonomyDefaultsRestored => 'Benutzerdefinierte Einträge gelöscht, Standards wiederhergestellt';

  @override
  String get taxonomyCourseName => 'Gang-Name';

  @override
  String get taxonomyCourseNameHint => 'z.B. Brunch, Vorspeise';

  @override
  String get taxonomyCategoryName => 'Kategorie-Name';

  @override
  String get taxonomyCategoryNameHint => 'z.B. Glutenfrei, Low-Carb';

  @override
  String get taxonomyEmojiHint => 'Tippe auf das Emoji-Feld um es zu ändern';

  @override
  String taxonomyDeleteCourseMessage(String name) {
    return '\"$name\" löschen? Rezepte mit diesem Gang werden ohne Kategorie.';
  }

  @override
  String taxonomyDeleteCategoryMessage(String name) {
    return '\"$name\" löschen? Rezepte mit dieser Kategorie werden ohne Kategorie.';
  }

  @override
  String get settingsQuickAccess => 'Schnellzugriff';

  @override
  String get settingsPlaceholders => 'Platzhalterbilder';

  @override
  String get actionView => 'Anzeigen';

  @override
  String get browseViewAll => 'Alle Rezepte Anzeigen';

  @override
  String browseRecipesTotal(int count) {
    return '$count Rezepte insgesamt';
  }

  @override
  String get browseCourses => 'Gänge';

  @override
  String get browseCategories => 'Kategorien';

  @override
  String get browseNoCourse => 'Kein Gang';

  @override
  String get browseUncategorized => 'Ohne Kategorie';

  @override
  String get favoritesTitle => 'Favoriten';

  @override
  String get favoritesEmpty => 'Noch keine Lieblingsrezepte';

  @override
  String get favoritesEmptySubtitle => 'Tippe auf den Stern eines Rezepts, um es hier hinzuzufügen';

  @override
  String get favoritesRemoved => 'Aus Favoriten entfernt';

  @override
  String get recentTitle => 'Kürzlich Angesehen';

  @override
  String get recentEmpty => 'Keine kürzlich angesehenen Rezepte';

  @override
  String get recentEmptySubtitle => 'Rezepte, die du ansiehst, erscheinen hier';

  @override
  String get recentJustNow => 'Gerade eben';

  @override
  String recentMinutesAgo(int count) {
    return 'Vor $count Min';
  }

  @override
  String recentHoursAgo(int count) {
    return 'Vor $count Stunden';
  }

  @override
  String get recentYesterday => 'Gestern';

  @override
  String recentDaysAgo(int count) {
    return 'Vor $count Tagen';
  }

  @override
  String get importFromUrl => 'Von URL importieren';

  @override
  String get importUrlHint => 'Rezept-URL';

  @override
  String get importUrlPlaceholder => 'https://beispiel.de/rezept';

  @override
  String get importFetch => 'Rezept Abrufen';

  @override
  String get importFetching => 'Wird abgerufen...';

  @override
  String get importPreview => 'Vorschau';

  @override
  String get importRecipeFound => 'Rezept gefunden!';

  @override
  String get importReviewSave => 'Überprüfen & Speichern';

  @override
  String get importEditBeforeSave => 'Du kannst das Rezept vor dem Speichern bearbeiten';

  @override
  String get importSupportedSites => 'Unterstützte Seiten';

  @override
  String get importSupportedSitesInfo => 'Funktioniert mit den meisten Rezeptseiten wie AllRecipes, Food Network, Tasty, BBC Good Food, Chefkoch, und vielen mehr!';

  @override
  String get importFromScan => 'Rezept Scannen';

  @override
  String get importFromPdf => 'Aus PDF Importieren';

  @override
  String get cookbookNew => 'Neues Kochbuch';

  @override
  String get cookbookNameLabel => 'Kochbuchname';

  @override
  String get cookbookNameHint => 'z.B. Familienrezepte';

  @override
  String get cookbookDescLabel => 'Beschreibung';

  @override
  String get cookbookDescHint => 'Eine Sammlung von Rezepten...';

  @override
  String get cookbookAddCover => 'Cover Hinzufügen';

  @override
  String get cookbookTapToAdd => 'Tippe um ein Coverbild hinzuzufügen';

  @override
  String get cookbookDeleteTitle => 'Kochbuch Löschen?';

  @override
  String cookbookDeleteMessage(int count) {
    return 'Dieses Kochbuch enthält $count Rezepte. Sie werden in den Papierkorb verschoben.';
  }

  @override
  String get cookbookCannotDelete => 'Du kannst dein einziges Kochbuch nicht löschen';

  @override
  String get fontSizeTitle => 'Textgröße';

  @override
  String get fontSizeReset => 'Zurücksetzen';

  @override
  String get fontSizeSmaller => 'Kleinerer Text';

  @override
  String get fontSizeLarger => 'Größerer Text';

  @override
  String get defaultCookbookName => 'Meine Rezepte';

  @override
  String get defaultCookbookDescription => 'Deine persönliche Rezeptsammlung';

  @override
  String get defaultShoppingListName => 'Einkaufsliste';

  @override
  String get courseBreakfast => 'Frühstück';

  @override
  String get courseLunch => 'Mittagessen';

  @override
  String get courseDinner => 'Abendessen';

  @override
  String get courseAppetizer => 'Vorspeise';

  @override
  String get courseSoup => 'Suppe';

  @override
  String get courseSalad => 'Salat';

  @override
  String get courseMain => 'Hauptgericht';

  @override
  String get courseSide => 'Beilage';

  @override
  String get courseDessert => 'Nachtisch';

  @override
  String get courseSnack => 'Snack';

  @override
  String get courseBeverage => 'Getränk';

  @override
  String get categoryQuick => 'Schnell & Einfach';

  @override
  String get categoryHealthy => 'Gesund';

  @override
  String get categoryComfort => 'Hausmannskost';

  @override
  String get categoryVegetarian => 'Vegetarisch';

  @override
  String get categoryVegan => 'Vegan';

  @override
  String get categoryGlutenFree => 'Glutenfrei';

  @override
  String get categoryDairyFree => 'Laktosefrei';

  @override
  String get categoryLowCarb => 'Low Carb';

  @override
  String get categorySpicy => 'Scharf';

  @override
  String get categoryFamilyFriendly => 'Familienfreundlich';

  @override
  String get categoryParty => 'Party';

  @override
  String get categoryHoliday => 'Feiertage';

  @override
  String get categoryBbq => 'Grillen';

  @override
  String get categoryBaking => 'Backen';

  @override
  String get shoppingProduce => 'Obst & Gemüse';

  @override
  String get shoppingDairy => 'Milchprodukte & Eier';

  @override
  String get shoppingMeat => 'Fleisch & Geflügel';

  @override
  String get shoppingSeafood => 'Fisch & Meeresfrüchte';

  @override
  String get shoppingBakery => 'Bäckerei';

  @override
  String get shoppingFrozen => 'Tiefkühl';

  @override
  String get shoppingPantry => 'Vorratskammer';

  @override
  String get shoppingSpices => 'Gewürze';

  @override
  String get shoppingBeverages => 'Getränke';

  @override
  String get shoppingSnacks => 'Snacks';

  @override
  String get shoppingInternational => 'International';

  @override
  String get shoppingOther => 'Sonstiges';

  @override
  String get unitCup => 'Tasse';

  @override
  String get unitCups => 'Tassen';

  @override
  String get unitTablespoon => 'Esslöffel';

  @override
  String get unitTablespoonAbbrev => 'EL';

  @override
  String get unitTeaspoon => 'Teelöffel';

  @override
  String get unitTeaspoonAbbrev => 'TL';

  @override
  String get unitFluidOunce => 'Flüssigunze';

  @override
  String get unitFluidOunceAbbrev => 'fl oz';

  @override
  String get unitPint => 'Pint';

  @override
  String get unitQuart => 'Quart';

  @override
  String get unitGallon => 'Gallone';

  @override
  String get unitMilliliter => 'Milliliter';

  @override
  String get unitMilliliterAbbrev => 'ml';

  @override
  String get unitLiter => 'Liter';

  @override
  String get unitLiterAbbrev => 'L';

  @override
  String get unitOunce => 'Unze';

  @override
  String get unitOunceAbbrev => 'oz';

  @override
  String get unitPound => 'Pfund';

  @override
  String get unitPoundAbbrev => 'lb';

  @override
  String get unitGram => 'Gramm';

  @override
  String get unitGramAbbrev => 'g';

  @override
  String get unitKilogram => 'Kilogramm';

  @override
  String get unitKilogramAbbrev => 'kg';

  @override
  String get unitPinch => 'Prise';

  @override
  String get unitDash => 'Spritzer';

  @override
  String get unitClove => 'Zehe';

  @override
  String get unitCloves => 'Zehen';

  @override
  String get unitHead => 'Kopf';

  @override
  String get unitBunch => 'Bund';

  @override
  String get unitCan => 'Dose';

  @override
  String get unitPackage => 'Packung';

  @override
  String get unitSlice => 'Scheibe';

  @override
  String get unitSlices => 'Scheiben';

  @override
  String get unitPiece => 'Stück';

  @override
  String get unitPieces => 'Stück';

  @override
  String get unitWhole => 'ganz';

  @override
  String get unitLarge => 'groß';

  @override
  String get unitMedium => 'mittel';

  @override
  String get unitSmall => 'klein';

  @override
  String get unitFahrenheit => '°F';

  @override
  String get unitCelsius => '°C';

  @override
  String get unitInch => 'Zoll';

  @override
  String get unitInches => 'Zoll';

  @override
  String get unitInchAbbrev => 'Zoll';

  @override
  String get unitCentimeter => 'Zentimeter';

  @override
  String get unitCentimeterAbbrev => 'cm';

  @override
  String get unitMillimeter => 'Millimeter';

  @override
  String get unitMillimeterAbbrev => 'mm';

  @override
  String get convertUnitsTitle => 'Einheiten umrechnen';

  @override
  String get convertMetricToImperial => 'Metrisch → Imperial';

  @override
  String get convertMetricToImperialDesc => 'ml → fl oz, g → oz, kg → lb';

  @override
  String get convertImperialToMetric => 'Imperial → Metrisch';

  @override
  String get convertImperialToMetricDesc => 'Tassen → ml, oz → g, TL → ml';

  @override
  String get convertResetToOriginal => 'Zurücksetzen';

  @override
  String get settingsRecipeLayout => 'Rezept-Layout';

  @override
  String get settingsRecipeLayoutDescription => 'Wähle, wie Zutaten und Anleitung angezeigt werden';

  @override
  String get settingsRecipeDisplay => 'Rezeptanzeige';

  @override
  String get layoutStacked => 'Gestapelt';

  @override
  String get layoutStackedDescription => 'Alle Inhalte in einer scrollbaren Liste anzeigen';

  @override
  String get layoutTabbed => 'Tabs';

  @override
  String get layoutTabbedDescription => 'Wischen zwischen Zutaten und Anleitung';

  @override
  String get recipeSwipeHint => 'Wischen zum Wechseln';

  @override
  String get recipeIngredients => 'Zutaten';

  @override
  String get recipeInstructions => 'Zubereitung';

  @override
  String get dateNextWeek => 'Nächste Woche';

  @override
  String get timeJustNow => 'Gerade eben';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Minuten',
      one: 'Vor 1 Minute',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Stunden',
      one: 'Vor 1 Stunde',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Tagen',
      one: 'Vor 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String timeWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Wochen',
      one: 'Vor 1 Woche',
    );
    return '$_temp0';
  }

  @override
  String timeMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Monaten',
      one: 'Vor 1 Monat',
    );
    return '$_temp0';
  }

  @override
  String timeYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Jahren',
      one: 'Vor 1 Jahr',
    );
    return '$_temp0';
  }

  @override
  String timeInMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Minuten',
      one: '1 Minute',
    );
    return 'in $_temp0';
  }

  @override
  String timeInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stunden',
      one: '1 Stunde',
    );
    return 'in $_temp0';
  }

  @override
  String durationMinutes(int count) {
    return '$count Min.';
  }

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Std.',
      one: '1 Std.',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours Std. $minutes Min.';
  }

  @override
  String countRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Rezepte',
      one: '1 Rezept',
      zero: 'Keine Rezepte',
    );
    return '$_temp0';
  }

  @override
  String countIngredients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zutaten',
      one: '1 Zutat',
      zero: 'Keine Zutaten',
    );
    return '$_temp0';
  }

  @override
  String countSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Schritte',
      one: '1 Schritt',
      zero: 'Keine Schritte',
    );
    return '$_temp0';
  }

  @override
  String countItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Artikel',
      one: '1 Artikel',
      zero: 'Keine Artikel',
    );
    return '$_temp0';
  }

  @override
  String countSelected(int count) {
    return '$count ausgewählt';
  }

  @override
  String get errorGenericTitle => 'Fehler';

  @override
  String get errorGenericMessage => 'Etwas ist schiefgelaufen. Bitte versuche es erneut.';

  @override
  String get errorNetworkTitle => 'Verbindungsfehler';

  @override
  String get errorNetworkMessage => 'Bitte überprüfe deine Internetverbindung und versuche es erneut.';

  @override
  String get errorNotFoundTitle => 'Nicht Gefunden';

  @override
  String get errorNotFoundMessage => 'Der angeforderte Inhalt konnte nicht gefunden werden.';

  @override
  String get errorInvalidUrlTitle => 'Ungültige URL';

  @override
  String get errorInvalidUrlMessage => 'Bitte gib eine gültige URL ein, die mit http:// oder https:// beginnt';

  @override
  String get errorPermissionDenied => 'Berechtigung verweigert';

  @override
  String get errorStorageFull => 'Speicher voll';

  @override
  String get errorFileNotFound => 'Datei nicht gefunden';

  @override
  String get errorUnsupportedFormat => 'Nicht unterstütztes Dateiformat';

  @override
  String get errorParsingFailed => 'Fehler beim Analysieren des Inhalts';

  @override
  String get errorSaveFailed => 'Speichern fehlgeschlagen';

  @override
  String get errorLoadFailed => 'Laden fehlgeschlagen';

  @override
  String get errorDeleteFailed => 'Löschen fehlgeschlagen';

  @override
  String get errorImportFailed => 'Import fehlgeschlagen';

  @override
  String get errorExportFailed => 'Export fehlgeschlagen';

  @override
  String get errorCameraAccess => 'Kein Zugriff auf die Kamera';

  @override
  String get errorGalleryAccess => 'Kein Zugriff auf die Fotobibliothek';

  @override
  String get errorTimeout => 'Zeitüberschreitung der Anfrage';

  @override
  String get errorServerError => 'Serverfehler. Bitte versuche es später erneut.';

  @override
  String get errorNoRecipeFound => 'Keine Rezeptdaten auf dieser Seite gefunden';

  @override
  String get errorInvalidRecipe => 'Ungültige Rezeptdaten';

  @override
  String get errorDuplicateRecipe => 'Dieses Rezept existiert bereits';

  @override
  String get validationRequired => 'Dieses Feld ist erforderlich';

  @override
  String validationTooShort(int min) {
    return 'Muss mindestens $min Zeichen haben';
  }

  @override
  String validationTooLong(int max) {
    return 'Muss weniger als $max Zeichen haben';
  }

  @override
  String get validationInvalidEmail => 'Bitte gib eine gültige E-Mail ein';

  @override
  String get validationInvalidUrl => 'Bitte gib eine gültige URL ein';

  @override
  String get validationInvalidNumber => 'Bitte gib eine gültige Zahl ein';

  @override
  String validationMinValue(int min) {
    return 'Muss mindestens $min sein';
  }

  @override
  String validationMaxValue(int max) {
    return 'Muss höchstens $max sein';
  }

  @override
  String get photoTakePhoto => 'Foto aufnehmen';

  @override
  String get photoChooseFromGallery => 'Aus Galerie Wählen';

  @override
  String get photoRemoveImage => 'Bild Entfernen';

  @override
  String get shareAsText => 'Text';

  @override
  String get shareAsImage => 'Bild';

  @override
  String get shareAsFile => 'Als Datei Teilen';

  @override
  String get shareQrCode => 'Rezept QR-Code';

  @override
  String get languageSystem => 'Systemstandard';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get scalingOriginal => 'Original';

  @override
  String get scalingHalf => 'Halb';

  @override
  String get scalingDouble => 'Doppelt';

  @override
  String get scalingTriple => 'Dreifach';

  @override
  String get scalingCustom => 'Benutzerdefiniert';

  @override
  String scalingServings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Portionen',
      one: '1 Portion',
    );
    return '$_temp0';
  }

  @override
  String get importRecipe => 'Rezept Importieren';

  @override
  String get importFile => 'Datei';

  @override
  String get importImage => 'Bild';

  @override
  String get importPaste => 'Einfügen';

  @override
  String get importPasteUrl => 'Rezept-URL einfügen';

  @override
  String get importOr => 'ODER';

  @override
  String get importSupportsFormats => 'Unterstützt Paprika, Mela, JSON, ZIP-Exporte';

  @override
  String get importFromSocialMedia => 'Importiere deine Rezepte von Social Media oder Websites.';

  @override
  String get tagsTitle => 'Tags';

  @override
  String get tagsSelect => 'Tags Auswählen';

  @override
  String get tagsNoTags => 'Noch keine Tags';

  @override
  String get tagsCreate => 'Tag Erstellen';

  @override
  String get tagsCreateNew => 'Neuen Tag erstellen';

  @override
  String get tagsEnterName => 'Tag-Name eingeben';

  @override
  String get tagsSearch => 'Tags suchen...';

  @override
  String get tagsSuggested => 'Vorgeschlagene Tags';

  @override
  String get tagsRecent => 'Kürzlich verwendet';

  @override
  String get tagsAll => 'Alle Tags';

  @override
  String get tagVegetarian => 'Vegetarisch';

  @override
  String get tagVegan => 'Vegan';

  @override
  String get tagGlutenFree => 'Glutenfrei';

  @override
  String get tagDairyFree => 'Milchfrei';

  @override
  String get tagNutFree => 'Nussfrei';

  @override
  String get tagLowCarb => 'Low Carb';

  @override
  String get tagKeto => 'Keto';

  @override
  String get tagPaleo => 'Paleo';

  @override
  String get tagWhole30 => 'Whole30';

  @override
  String get tagQuick => 'Schnell';

  @override
  String get tagEasy => 'Einfach';

  @override
  String get tagHealthy => 'Gesund';

  @override
  String get tagComfortFood => 'Soulfood';

  @override
  String get tagFamilyFriendly => 'Familienfreundlich';

  @override
  String get tagKidFriendly => 'Kinderfreundlich';

  @override
  String get tagMealPrep => 'Meal Prep';

  @override
  String get tagOnePot => 'Ein-Topf';

  @override
  String get tagInstantPot => 'Instant Pot';

  @override
  String get tagSlowCooker => 'Slow Cooker';

  @override
  String get tagAirFryer => 'Heißluftfritteuse';

  @override
  String get tagGrill => 'Grill';

  @override
  String get tagBBQ => 'BBQ';

  @override
  String get tagHoliday => 'Feiertag';

  @override
  String get tagParty => 'Party';

  @override
  String get tagBudget => 'Budget';

  @override
  String get tagSpicy => 'Scharf';

  @override
  String get tagSweet => 'Süß';

  @override
  String get tagSavory => 'Herzhaft';

  @override
  String get tagLight => 'Leicht';

  @override
  String get tagHearty => 'Deftig';

  @override
  String get tagSummer => 'Sommer';

  @override
  String get tagWinter => 'Winter';

  @override
  String get tagFall => 'Herbst';

  @override
  String get tagSpring => 'Frühling';

  @override
  String get settingsImagePlaceholders => 'Bild-Platzhalter';

  @override
  String get settingsImagePlaceholdersSubtitle => 'Wähle, was angezeigt wird wenn Bilder fehlen';

  @override
  String get settingsQuickAccessSubtitle => 'Konfiguriere was im Schnellzugriff erscheint';

  @override
  String get settingsManageCoursesSubtitle => 'Gänge hinzufügen, bearbeiten oder entfernen';

  @override
  String get settingsManageCategoriesSubtitle => 'Kategorien hinzufügen, bearbeiten oder entfernen';

  @override
  String get settingsShoppingCategories => 'Einkaufskategorien';

  @override
  String get settingsShoppingCategoriesSubtitle => 'Artikel nach Gang organisieren';

  @override
  String get shoppingIngredientMappings => 'Zutatenzuordnungen';

  @override
  String shoppingPriority(int priority) {
    return 'Priorität: $priority';
  }

  @override
  String get shoppingAddCategory => 'Kategorie hinzufügen';

  @override
  String get shoppingEditCategory => 'Kategorie bearbeiten';

  @override
  String get shoppingDeleteCategory => 'Kategorie löschen?';

  @override
  String shoppingDeleteCategoryMessage(String name) {
    return '\"$name\" löschen? Artikel in dieser Kategorie werden ohne Kategorie.';
  }

  @override
  String get shoppingCategoryName => 'Name';

  @override
  String get shoppingSearchIngredients => 'Zutaten suchen...';

  @override
  String shoppingMappingsInfo(int count) {
    return 'Tippe auf die Kategorie um die Zuordnung zu ändern. ($count Zuordnungen)';
  }

  @override
  String shoppingCategoryFor(String ingredient) {
    return 'Kategorie für \"$ingredient\"';
  }

  @override
  String shoppingMovedTo(String ingredient, String category) {
    return '\"$ingredient\" verschoben nach $category';
  }

  @override
  String shoppingResetToDefault(String ingredient) {
    return '\"$ingredient\" auf Standard zurückgesetzt';
  }

  @override
  String get actionReset => 'Zurücksetzen';

  @override
  String shoppingMappingMoved(String ingredient, String category) {
    return '\"$ingredient\" nach $category verschoben';
  }

  @override
  String shoppingMappingReset(String ingredient) {
    return '\"$ingredient\" auf Standard zurückgesetzt';
  }

  @override
  String get addPhoto => 'Foto Hinzufügen';

  @override
  String get addPhotoSubtitle => 'Tippe um aus Galerie oder Kamera auszuwählen';

  @override
  String get viewAllRecipes => 'Alle Rezepte anzeigen';

  @override
  String recipesTotal(int count) {
    return '$count Rezepte insgesamt';
  }

  @override
  String get coursesTitle => 'Gänge';

  @override
  String get categoriesTitle => 'Kategorien';

  @override
  String get courseBrunch => 'Brunch';

  @override
  String get courseMainDish => 'Hauptgericht';

  @override
  String get courseSideDish => 'Beilage';

  @override
  String get courseSauce => 'Soße';

  @override
  String get courseBread => 'Brot';

  @override
  String get categoryBean => 'Bohnen';

  @override
  String get categoryBread => 'Brot';

  @override
  String get categoryBurritoTaco => 'Burrito/Taco';

  @override
  String get categoryCasserole => 'Auflauf';

  @override
  String get categoryChickenSteakMeat => 'Hähnchen/Steak/Fleisch';

  @override
  String get categoryDessert => 'Nachtisch';

  @override
  String get categoryFish => 'Fisch';

  @override
  String get categoryFruit => 'Obst';

  @override
  String get categoryPasta => 'Pasta';

  @override
  String get categoryPizza => 'Pizza';

  @override
  String get categoryPork => 'Schwein';

  @override
  String get categoryRice => 'Reis';

  @override
  String get categorySandwich => 'Sandwich';

  @override
  String get categorySeafood => 'Meeresfrüchte';

  @override
  String get categorySoup => 'Suppe';

  @override
  String get categoryVegetable => 'Gemüse';

  @override
  String get or => 'oder';

  @override
  String get and => 'und';

  @override
  String get wordOf => 'von';

  @override
  String get items => 'Artikel';

  @override
  String get more => 'mehr';

  @override
  String get less => 'weniger';

  @override
  String get all => 'Alle';

  @override
  String get none => 'Keine';

  @override
  String get other => 'Andere';

  @override
  String get custom => 'Benutzerdefiniert';

  @override
  String get defaultValue => 'Standard';

  @override
  String get required => 'Erforderlich';

  @override
  String get optional => 'Optional';

  @override
  String get photoChooseGallery => 'Aus Galerie wählen';

  @override
  String get importFirstRecipe => 'Erstes importieren';

  @override
  String get importAllRecipes => 'Alle importieren';

  @override
  String get parseRecipe => 'Rezept analysieren';

  @override
  String get shareRecipe => 'Rezept teilen';

  @override
  String get shareExport => 'Exportieren';

  @override
  String shareServings(int count) {
    return 'Portionen: $count';
  }

  @override
  String sharePrep(int minutes) {
    return 'Vorbereitung: $minutes Min';
  }

  @override
  String shareCook(int minutes) {
    return 'Kochen: $minutes Min';
  }

  @override
  String get shareFromApp => 'Geteilt von Recipe Spellbook ✨';

  @override
  String get shareCreatingCard => 'Rezeptkarte wird erstellt...';

  @override
  String shareCheckRecipe(String title) {
    return 'Schau dir dieses Rezept an: $title';
  }

  @override
  String shareErrorImage(String error) {
    return 'Fehler beim Erstellen des Bildes: $error';
  }

  @override
  String get editItem => 'Eintrag bearbeiten';

  @override
  String get selectAll => 'Alle auswählen';

  @override
  String get selectNone => 'Keine auswählen';

  @override
  String get viewPlanner => 'Planer anzeigen';

  @override
  String get planNow => 'Jetzt planen';

  @override
  String get loadingText => 'Lädt...';

  @override
  String get errorText => 'Fehler';

  @override
  String get errorLoadingMeals => 'Fehler beim Laden der Mahlzeiten';

  @override
  String get readingImage => 'Bild wird gelesen...';

  @override
  String get parsingRecipe => 'Rezept wird analysiert...';

  @override
  String get noTextInImage => 'Kein Text im Bild gefunden';

  @override
  String failedProcessImage(String error) {
    return 'Bildverarbeitung fehlgeschlagen: $error';
  }

  @override
  String get cookingModeExit => 'Kochmodus beenden';

  @override
  String cookingModeStep(int current, int total) {
    return 'Schritt $current von $total';
  }

  @override
  String get cookingModePrevious => 'Zurück';

  @override
  String get cookingModeNext => 'Weiter';

  @override
  String get cookingModeFinish => 'Fertig';

  @override
  String get cookingModeCompleted => 'Rezept abgeschlossen!';

  @override
  String get cookingModeGreatJob => 'Gut gemacht! Guten Appetit.';

  @override
  String get mealPlanBreakfast => 'Frühstück';

  @override
  String get mealPlanLunch => 'Mittagessen';

  @override
  String get mealPlanDinner => 'Abendessen';

  @override
  String get mealPlanSnack => 'Snack';

  @override
  String get mealPlanAddMeal => 'Mahlzeit hinzufügen';

  @override
  String get mealPlanRemove => 'Aus Plan entfernen';

  @override
  String get mealPlanNoMeals => 'Keine Mahlzeiten geplant';

  @override
  String get mealPlanTapToAdd => 'Tippe + um eine Mahlzeit hinzuzufügen';

  @override
  String get thisWeek => 'Diese Woche';

  @override
  String get itemName => 'Artikelname';

  @override
  String get addToShoppingList => 'Zur Einkaufsliste hinzufügen';

  @override
  String get addToList => 'Zu Liste hinzufügen';

  @override
  String addedItemsToList(int count) {
    return '$count Artikel zur Einkaufsliste hinzugefügt';
  }

  @override
  String get scanToImport => 'Scannen um Rezept zu importieren';

  @override
  String xOfY(int current, int total) {
    return '$current von $total';
  }

  @override
  String addItems(int count) {
    return '$count Artikel hinzufügen';
  }

  @override
  String failedToParse(String error) {
    return 'Analyse fehlgeschlagen: $error';
  }

  @override
  String failedToImport(String error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get groupBy => 'Gruppieren nach';

  @override
  String get cookbookHint => 'Tippen zum Auswählen • Lange drücken zum Bearbeiten';

  @override
  String get rename => 'Umbenennen';

  @override
  String get renameCookbook => 'Kochbuch umbenennen';

  @override
  String get seeAll => 'Alle anzeigen';

  @override
  String get imagePlaceholders => 'Bildplatzhalter';

  @override
  String get imagePlaceholdersSubtitle => 'Wähle was angezeigt wird wenn Bilder fehlen';

  @override
  String get homeScreenSection => 'Startseite';

  @override
  String get quickAccessSubtitle => 'Konfiguriere was im Schnellzugriff erscheint';

  @override
  String get manageCoursesSubtitle => 'Gänge hinzufügen, bearbeiten oder entfernen';

  @override
  String get manageCategoriesSubtitle => 'Kategorien hinzufügen, bearbeiten oder entfernen';

  @override
  String get shoppingCategoriesSubtitle => 'Artikel nach Gang ordnen';

  @override
  String get syncSection => 'Synchronisation';

  @override
  String get cloudSync => 'Cloud-Sync';

  @override
  String get comingSoon => 'Demnächst verfügbar';

  @override
  String get resetApp => 'App zurücksetzen';

  @override
  String get resetAppSubtitle => 'Alle Daten dauerhaft löschen';

  @override
  String get trashSubtitle => 'Gelöschte Rezepte (30 Tage Aufbewahrung)';

  @override
  String get importRecipeTitle => 'Rezept importieren';

  @override
  String get importSocialMedia => 'Importiere Rezepte von Social Media oder Webseiten.';

  @override
  String get pasteRecipeUrl => 'Rezept-URL einfügen';

  @override
  String get orDivider => 'ODER';

  @override
  String get fileOption => 'Datei';

  @override
  String get imageOption => 'Bild';

  @override
  String get pasteOption => 'Einfügen';

  @override
  String get supportedFormats => 'Unterstützt Paprika, Mela, JSON, ZIP Exporte';

  @override
  String get pasteRecipeTitle => 'Rezept einfügen';

  @override
  String get pasteRecipeHint => 'Rezept hier einfügen...';

  @override
  String get quickAccessHelpIntro => 'Diese Badges zeigen an, warum Rezepte hier erscheinen:';

  @override
  String get quickAccessHelpMealPlan => 'Für heute geplant';

  @override
  String get quickAccessHelpPinned => 'Du hast dieses Rezept angeheftet';

  @override
  String get quickAccessHelpRecent => 'Kürzlich angesehen';

  @override
  String get openCalendar => 'Kalender öffnen';

  @override
  String get editNotes => 'Notizen bearbeiten';

  @override
  String get addNotesHint => 'Notizen hinzufügen...';

  @override
  String get moveToAnotherDay => 'Auf anderen Tag verschieben';

  @override
  String get addToPlan => 'Zum Plan hinzufügen';

  @override
  String importBulkQuestion(int count) {
    return 'Möchtest du alle $count Rezepte importieren oder einzeln auswählen?';
  }

  @override
  String get importingRecipes => 'Importiere Rezepte...';

  @override
  String importedRecipesCount(int count) {
    return '$count Rezepte importiert';
  }

  @override
  String get extractingArchive => 'Archiv wird entpackt...';

  @override
  String get themeSpellbook => 'Zauberbuch';

  @override
  String get themeForest => 'Wald';

  @override
  String get themeOcean => 'Ozean';

  @override
  String get themeSunset => 'Sonnenuntergang';

  @override
  String get themeMidnight => 'Mitternacht';

  @override
  String get themeRose => 'Rose';

  @override
  String get colorTheme => 'Farbthema';

  @override
  String get colorThemeSubtitle => 'Wähle die Farbpalette deiner App';

  @override
  String get preview => 'Vorschau';

  @override
  String get previewPrimary => 'Primär';

  @override
  String get previewSecondary => 'Sekundär';

  @override
  String get previewTertiary => 'Tertiär';

  @override
  String get previewError => 'Fehler';

  @override
  String get placeholderDescription => 'Wähle, was angezeigt wird, wenn Rezepte oder Kochbücher keine Bilder haben.';

  @override
  String get recipePlaceholders => 'Rezept-Platzhalter';

  @override
  String get cookbookPlaceholders => 'Kochbuch-Platzhalter';

  @override
  String get defaultImages => 'Standardbilder';

  @override
  String get defaultImagesDescription => 'Default app artwork for recipes and cookbooks';

  @override
  String get themeBased => 'Themenbasiert';

  @override
  String get themeBasedDescription => 'Farbverlauf mit Logo basierend auf deinem Farbthema';

  @override
  String get groupBySection => 'Nach Abteilung';

  @override
  String get groupByRecipe => 'Nach Rezept';

  @override
  String get groupByUngrouped => 'Ungruppiert';

  @override
  String get copyAsText => 'Als Text kopieren';

  @override
  String get printList => 'Liste drucken';

  @override
  String get manageLists => 'Listen verwalten';

  @override
  String get newList => 'Neu';

  @override
  String get newShoppingList => 'Neue Einkaufsliste';

  @override
  String get listNameHint => 'Listenname';

  @override
  String get recipeLayoutSetting => 'Rezept-Layout';

  @override
  String get recipeLayoutSettingSubtitle => 'Wähle, wie Rezeptdetails angezeigt werden';

  @override
  String get layoutTabbedOption => 'Tab-Ansicht';

  @override
  String get layoutStackedOption => 'Gestapelte Ansicht';

  @override
  String get nutrientsTitle => 'Nährwerte';

  @override
  String get nutrientsSubtitle => 'Nährwertangaben pro Portion';

  @override
  String get addNutrients => 'Nährwerte hinzufügen';

  @override
  String get calculateNutrients => 'Aus Zutaten berechnen';

  @override
  String get nutrientsDisclaimer => 'Nährwerte sind Schätzungen. Die Genauigkeit hängt von den Zutatenmessungen ab. Die Verwendung einer Küchenwaage mit Grammangaben liefert die beste Genauigkeit.';

  @override
  String get calories => 'Kalorien';

  @override
  String get protein => 'Eiweiß';

  @override
  String get carbohydrates => 'Kohlenhydrate';

  @override
  String get fat => 'Fett';

  @override
  String get fiber => 'Ballaststoffe';

  @override
  String get sugar => 'Zucker';

  @override
  String get sodium => 'Natrium';

  @override
  String get cholesterol => 'Cholesterin';

  @override
  String get saturatedFat => 'Gesättigte Fettsäuren';

  @override
  String get transFat => 'Transfette';

  @override
  String get servingSize => 'Portionsgröße';

  @override
  String get perServing => 'Pro Portion';

  @override
  String get calculatingNutrients => 'Nährwerte werden berechnet...';

  @override
  String get nutrientsCalculated => 'Nährwerte berechnet';

  @override
  String nutrientsFailed(String error) {
    return 'Nährwerte konnten nicht berechnet werden: $error';
  }

  @override
  String get premiumFeature => 'Premium-Funktion';

  @override
  String get premiumNutrientsDescription => 'Automatische Nährwertberechnung erfordert ein Premium-Abonnement';

  @override
  String get exportCurrentCookbook => 'Aktuelles Kochbuch exportieren';

  @override
  String get exporting => 'Exportiere...';

  @override
  String get exportAllCookbooks => 'Alle Kochbücher exportieren';

  @override
  String get importing => 'Importiere...';

  @override
  String get importFromJson => 'Aus JSON importieren';

  @override
  String get importFromJsonSubtitle => 'Backup-Datei auswählen';

  @override
  String get aboutDescription => 'Dein magischer Rezeptbegleiter zum Organisieren, Planen und Kochen köstlicher Mahlzeiten.';

  @override
  String get madeWithLove => 'Mit ❤️ gemacht für Hobbyköche überall';

  @override
  String get resetAppWarning => 'Dies löscht dauerhaft alle deine Rezepte, Mahlzeitenpläne, Einkaufslisten und Einstellungen. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get actionContinue => 'Fortfahren';

  @override
  String get finalConfirmation => 'Letzte Bestätigung';

  @override
  String get typeDeleteToConfirm => 'Tippe LÖSCHEN zum Bestätigen';

  @override
  String get typeDeleteHint => 'LÖSCHEN';

  @override
  String get resetScopeLocal => 'lokale Daten';

  @override
  String get resetScopeCloud => 'Cloud-Daten';

  @override
  String get resetScopeAll => 'alle Daten und Einstellungen';

  @override
  String get resetEverything => 'Alles zurücksetzen';

  @override
  String get resettingApp => 'App wird zurückgesetzt...';

  @override
  String get appResetSuccess => 'App erfolgreich zurückgesetzt';

  @override
  String get resetFailed => 'Zurücksetzen fehlgeschlagen';

  @override
  String get successAdded => 'Erfolgreich hinzugefügt';

  @override
  String get selectToday => 'Heute auswählen';

  @override
  String get selectTomorrow => 'Morgen auswählen';

  @override
  String get addedManually => 'Manuell hinzugefügt';

  @override
  String get unknownRecipe => 'Unbekanntes Rezept';

  @override
  String get shoppingListEmpty => 'Deine Einkaufsliste ist leer';

  @override
  String get shoppingListEmptyHint => 'Füge Artikel hinzu oder importiere aus Rezepten';

  @override
  String get settingsKitchenBuddyActive => 'Magischen Text beschwören...';

  @override
  String get shoppingCheckAll => 'Alle abhaken';

  @override
  String get shoppingUncheckAll => 'Alle Häkchen entfernen';

  @override
  String get shoppingManageLists => 'Listen verwalten';

  @override
  String get shoppingNewList => 'Neue Einkaufsliste';

  @override
  String get shoppingListName => 'Listenname';

  @override
  String get shoppingLists => 'Einkaufslisten';

  @override
  String get shoppingRenameList => 'Liste umbenennen';

  @override
  String get shoppingDeleteList => 'Liste löschen?';

  @override
  String get categoryProduce => 'Obst & Gemüse';

  @override
  String get categoryDairy => 'Milchprodukte';

  @override
  String get categoryMeat => 'Fleisch';

  @override
  String get categoryBakery => 'Backwaren';

  @override
  String get categoryFrozen => 'Tiefkühl';

  @override
  String get categoryBeverages => 'Getränke';

  @override
  String get categoryPantry => 'Vorratskammer';

  @override
  String get categorySpices => 'Gewürze';

  @override
  String get categoryInternational => 'International';

  @override
  String get categorySnacks => 'Snacks';

  @override
  String get categoryOther => 'Sonstiges';

  @override
  String get from => 'von';

  @override
  String get deleted => 'gelöscht';

  @override
  String get currently => 'Aktuell in';

  @override
  String get autoDetect => 'Automatisch erkennen';

  @override
  String get category => 'Kategorie';

  @override
  String get actionNew => 'Neu';

  @override
  String get actionCreate => 'Erstellen';

  @override
  String get tagsAdd => 'Tag hinzufügen';

  @override
  String get tagsSearchOrCreate => 'Tag suchen oder erstellen...';

  @override
  String get tagsNoResults => 'Keine passenden Tags gefunden';

  @override
  String get color => 'Farbe';

  @override
  String get icon => 'Symbol';

  @override
  String get nutritionTitle => 'Nährwerte';

  @override
  String get nutritionEmpty => 'Keine Nährwertdaten';

  @override
  String get nutritionEmptyHint => 'Bearbeite dieses Rezept und berechne die Nährwerte aus den Zutaten';

  @override
  String get scaled => 'skaliert';

  @override
  String get nutritionCalculate => 'Nährwerte berechnen';

  @override
  String get nutritionCalculating => 'Berechne Nährwerte...';

  @override
  String get nutritionMatchingIngredients => 'Gleiche Zutaten mit USDA-Datenbank ab';

  @override
  String get nutritionCalculationFailed => 'Nährwerte konnten nicht berechnet werden';

  @override
  String get nutritionDisclaimer => 'Nährwerte sind Schätzungen basierend auf USDA-Daten. Tatsächliche Werte können je nach Produkt, Zubereitung und Portionsgröße variieren.';

  @override
  String get nutritionPerServing => 'Pro Portion';

  @override
  String nutritionServings(int count) {
    return '$count Portionen';
  }

  @override
  String get nutritionIngredientBreakdown => 'Zutaten-Aufschlüsselung';

  @override
  String get nutritionIngredientsMatched => 'Zutaten zugeordnet';

  @override
  String nutritionMatchedCount(int matched, int total) {
    return '$matched von $total zugeordnet';
  }

  @override
  String nutritionUncertainCount(int count) {
    return '$count zur Überprüfung';
  }

  @override
  String get nutritionUncertain => 'Zuordnung prüfen';

  @override
  String get nutritionNotFound => 'Keine Übereinstimmung - tippen zum Suchen';

  @override
  String get nutritionRecalculate => 'Neu berechnen';

  @override
  String get nutritionOverwriteTitle => 'Nährwerte überschreiben?';

  @override
  String get nutritionOverwriteMessage => 'Dieses Rezept hat bereits Nährwertdaten. Möchtest du sie neu berechnen und ersetzen?';

  @override
  String get nutritionCalculated => 'Nährwerte erfolgreich berechnet';

  @override
  String get nutritionSave => 'Nährwerte speichern';

  @override
  String get nutritionSelectFood => 'USDA-Lebensmittel auswählen';

  @override
  String get nutritionSearchFood => 'Lebensmittel suchen...';

  @override
  String get nutritionNoResults => 'Keine Ergebnisse gefunden';

  @override
  String get nutritionCalories => 'Kalorien';

  @override
  String get nutritionProtein => 'Eiweiß';

  @override
  String get nutritionCarbs => 'Kohlenhydrate';

  @override
  String get nutritionFat => 'Fett gesamt';

  @override
  String get nutritionSaturatedFat => 'Gesättigte Fettsäuren';

  @override
  String get nutritionTransFat => 'Transfette';

  @override
  String get nutritionFiber => 'Ballaststoffe';

  @override
  String get nutritionSugar => 'Zucker';

  @override
  String get nutritionCholesterol => 'Cholesterin';

  @override
  String get nutritionSodium => 'Natrium';

  @override
  String get nutritionPotassium => 'Kalium';

  @override
  String get nutritionCalcium => 'Calcium';

  @override
  String get nutritionIron => 'Eisen';

  @override
  String get nutritionVitaminA => 'Vitamin A';

  @override
  String get nutritionVitaminC => 'Vitamin C';

  @override
  String get nutritionVitaminD => 'Vitamin D';

  @override
  String get layoutInfoText => 'Nährwertdaten (falls berechnet) werden in beiden Layouts angezeigt. Das Tab-Layout ermöglicht das Wischen zwischen Abschnitten.';

  @override
  String get settingsManageTagsSubtitle => 'Rezept-Tags erstellen und organisieren';

  @override
  String get nutritionTotal => 'Gesamt';

  @override
  String get nutritionAutoCalculate => 'Automatisch berechnen';

  @override
  String get nutritionManualEntry => 'Manuell eingeben';

  @override
  String get nutritionManualEntryTitle => 'Bekannte Werte eingeben';

  @override
  String get nutritionManualEntryDescription => 'Wenn Sie die genauen Nährwerte kennen (von der Verpackung, Website usw.), geben Sie sie hier ein.';

  @override
  String get nutritionMainNutrients => 'Hauptnährstoffe';

  @override
  String get nutritionOtherNutrients => 'Weitere Nährstoffe';

  @override
  String get nutritionEnterAtLeastOne => 'Geben Sie mindestens Kalorien oder einen Makronährstoff ein';

  @override
  String get nutritionHowToFix => 'Wie korrigieren';

  @override
  String get nutritionHowToImproveAccuracy => 'So verbessern Sie die Genauigkeit';

  @override
  String get nutritionEditIngredient => 'Zutat bearbeiten';

  @override
  String get nutritionSearchUsda => 'USDA durchsuchen';

  @override
  String get nutritionEnterManually => 'Manuell eingeben';

  @override
  String get nutritionManualIngredientHint => 'Geben Sie die Nährwerte für diese Zutatenmenge ein. Überprüfen Sie das Verpackungsetikett oder eine Nährwertdatenbank.';

  @override
  String get nutritionApplyManual => 'Manuelle Werte anwenden';

  @override
  String get nutritionTotalRecipe => 'Gesamtes Rezept';

  @override
  String get nutritionMatchRate => 'Übereinstimmungsrate';

  @override
  String get allergySettingsTitle => 'Allergie-Einstellungen';

  @override
  String get allergyInfoText => 'Wählen Sie unten Ihre Allergene aus. Recipe Spellbook warnt Sie, wenn Rezepte Zutaten enthalten, gegen die Sie allergisch sind.';

  @override
  String allergySelectedCount(int count) {
    return '$count Allergene ausgewählt';
  }

  @override
  String get allergySelectAll => 'Alle auswählen';

  @override
  String get allergyClearAll => 'Alle löschen';

  @override
  String get allergyMajorTitle => 'Hauptallergene';

  @override
  String get allergyMajorSubtitle => 'Von der FDA anerkannte Hauptnahrungsmittelallergene';

  @override
  String get allergyAdditionalTitle => 'Zusätzliche Allergene';

  @override
  String get allergyAdditionalSubtitle => 'Andere häufige Nahrungsmittelunverträglichkeiten';

  @override
  String get allergyWillWarn => 'Sie werden vor diesem Allergen gewarnt';

  @override
  String get allergyWarningTitle => '⚠️ Allergie-Warnung';

  @override
  String get allergyWarningTitlePossible => '⚠️ Mögliche Allergene';

  @override
  String get allergyContains => 'Enthält:';

  @override
  String get allergyMayContain => 'Kann enthalten:';

  @override
  String get allergyContainsAllergens => 'Enthält Allergene';

  @override
  String get allergyManageSettings => 'Allergie-Einstellungen verwalten';

  @override
  String get allergyDetailsTitle => 'Allergen-Details';

  @override
  String get settingsAllergies => 'Allergien';

  @override
  String get settingsAllergiesSubtitle => 'Allergen-Warnungen einrichten';

  @override
  String get allergenMilk => 'Milch/Milchprodukte';

  @override
  String get allergenEggs => 'Eier';

  @override
  String get allergenFish => 'Fisch';

  @override
  String get allergenShellfish => 'Schalentiere';

  @override
  String get allergenTreeNuts => 'Baumnüsse';

  @override
  String get allergenPeanuts => 'Erdnüsse';

  @override
  String get allergenWheat => 'Weizen/Gluten';

  @override
  String get allergenSoy => 'Soja';

  @override
  String get allergenSesame => 'Sesam';

  @override
  String get allergenMustard => 'Senf';

  @override
  String get allergenCelery => 'Sellerie';

  @override
  String get allergenLupin => 'Lupine';

  @override
  String get allergenMollusks => 'Weichtiere';

  @override
  String get allergenSulfites => 'Sulfite';

  @override
  String get allergenCorn => 'Mais';

  @override
  String get allergenNightshades => 'Nachtschattengewächse';

  @override
  String get nutritionCopyFromAuto => 'Von Auto-Berechnung kopieren';

  @override
  String get nutritionEstimatedDisclaimer => 'Werte basieren auf USDA-Daten';

  @override
  String get actionDiscard => 'Verwerfen';

  @override
  String get unsavedChangesTitle => 'Ungespeicherte Änderungen';

  @override
  String get unsavedChangesMessage => 'Sie haben ungespeicherte Änderungen. Möchten Sie diese speichern?';

  @override
  String get tagsEmptyTitle => 'Noch keine Tags';

  @override
  String get tagsEmptySubtitle => 'Erstellen Sie Tags, um Ihre Rezepte nach Ernährungsbedürfnissen, Mahlzeitenart und mehr zu organisieren.';

  @override
  String get tagsLoadDefaults => 'Standard-Tags laden';

  @override
  String get tagsAddNew => 'Tag hinzufügen';

  @override
  String get tagsEdit => 'Tag bearbeiten';

  @override
  String get tagsDelete => 'Tag löschen';

  @override
  String tagsDeleteConfirm(String name) {
    return 'Möchten Sie \"$name\" wirklich löschen?';
  }

  @override
  String get tagsNameLabel => 'Tag-Name';

  @override
  String get tagsIconLabel => 'Symbol (Emoji)';

  @override
  String get tagsColorLabel => 'Farbe';

  @override
  String get settingsKitchenBuddyEnabled => 'Earn coins and dress up your buddy!';

  @override
  String get settingsRecipeLayoutSubtitle => 'Anpassen, wie Rezepte angezeigt werden';

  @override
  String get shareLink => 'Link';

  @override
  String get shareDocument => 'Dokument';

  @override
  String get sharePrint => 'Drucken';

  @override
  String get shareLinkDescription => 'Teile einen Link, über den andere dieses Rezept ansehen können.';

  @override
  String get shareLinkNote => 'Empfänger benötigen die Recipe Spellbook App oder können im Web ansehen.';

  @override
  String get shareCreatingDocument => 'Dokument wird erstellt...';

  @override
  String get editLayoutTitle => 'Bearbeitungslayout';

  @override
  String get editLayoutStacked => 'Gestapelt';

  @override
  String get editLayoutTabbed => 'Tabs';

  @override
  String get editLayoutStackedDesc => 'Alle Abschnitte in einer scrollbaren Ansicht';

  @override
  String get editLayoutTabbedDesc => 'Separate Tabs für Details, Zutaten, Anleitung';

  @override
  String get tabDetails => 'Details';

  @override
  String get tabIngredients => 'Zutaten';

  @override
  String get tabInstructions => 'Anleitung';

  @override
  String get stepImageAdd => 'Bild hinzufügen';

  @override
  String get stepImageChange => 'Bild ändern';

  @override
  String get stepImageRemove => 'Bild entfernen';

  @override
  String get stepTimer => 'Timer';

  @override
  String stepTimerMinutes(int minutes) {
    return '$minutes Min';
  }

  @override
  String get recipeAddToCookbook => 'Zum Kochbuch hinzufügen';

  @override
  String get recipeMoveToTrash => 'In Papierkorb verschieben';

  @override
  String get tagsEmpty => 'Keine Tags';

  @override
  String get nutritionPerServingLabel => 'Pro Portion';

  @override
  String get nutritionTotalLabel => 'Gesamtes Rezept';

  @override
  String get trendingRecipes => 'Beliebte Rezepte';

  @override
  String get addShortcut => 'Recipe Spellbook Verknüpfung hinzufügen';

  @override
  String get addShortcutSubtitle => 'Rezepte mit einem Tipp importieren';

  @override
  String get importGuides => 'Unsere Import-Anleitungen lesen';

  @override
  String get useOnDesktop => 'Recipe Spellbook auf dem Desktop verwenden';

  @override
  String get inviteFriends => 'Freunde einladen';

  @override
  String get inviteFriendsTitle => 'Recipe Spellbook teilen';

  @override
  String get inviteFriendsSubtitle => 'Lade deine Freunde und Familie ein, gemeinsam zu kochen!';

  @override
  String get shareApp => 'App teilen';

  @override
  String get maybeLater => 'Vielleicht später';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get upgradeToPremium => 'Auf Premium upgraden';

  @override
  String get premiumSubtitle => 'Synchronisierung, unbegrenzte Rezepte & mehr';

  @override
  String get leaderboards => 'Bestenlisten';

  @override
  String get achievements => 'Erfolge';

  @override
  String get cookingStats => 'Koch-Statistiken';

  @override
  String get stepByStepGuides => 'Schritt-für-Schritt Anleitungen';

  @override
  String get importGuidesSubtitle => 'Erfahre, wie du Rezepte aus deinen Lieblings-Apps und Websites importierst';

  @override
  String get importFromOtherApps => 'Aus anderen Apps importieren';

  @override
  String get orderOnline => 'Online bestellen';

  @override
  String get helpTitle => 'Hilfe';

  @override
  String get navMenu => 'Menü';

  @override
  String get mealPlanTitle => 'Mein Essensplan';

  @override
  String get noRecipesYet => 'Noch keine Rezepte';

  @override
  String get breakfast => 'Frühstück';

  @override
  String get lunch => 'Mittagessen';

  @override
  String get dinner => 'Abendessen';

  @override
  String get snack => 'Snack';

  @override
  String get allergenGluten => 'Gluten';

  @override
  String get allergenChocolate => 'Schokolade & Kakao';

  @override
  String get allergenCaffeine => 'Koffein';

  @override
  String get allergenAlcohol => 'Alkohol';

  @override
  String get allergenCitrus => 'Zitrusfrüchte';

  @override
  String get allergenStoneFruits => 'Steinobst';

  @override
  String get allergenCoconut => 'Kokosnuss';

  @override
  String get allergenGarlic => 'Knoblauch';

  @override
  String get allergenOnion => 'Zwiebel';

  @override
  String get allergenMushrooms => 'Pilze';

  @override
  String get allergenAvocado => 'Avocado';

  @override
  String get allergenBanana => 'Banane';

  @override
  String get allergenKiwi => 'Kiwi';

  @override
  String get allergenLatexFoods => 'Latex-Kreuzreaktiv';

  @override
  String get allergenFodmap => 'Hoher FODMAP-Gehalt';

  @override
  String get allergenHistamine => 'Hoher Histamingehalt';

  @override
  String get allergenSalicylates => 'Salicylate';

  @override
  String get allergenMsg => 'Glutamat';

  @override
  String get allergenRedMeat => 'Rotes Fleisch (Alpha-Gal)';

  @override
  String get allergenGelatin => 'Gelatine';

  @override
  String get allergyWarningContains => 'Kann enthalten:';

  @override
  String get allergyDismissForRecipe => 'Für dieses Rezept ausblenden';

  @override
  String get allergyDismissUndo => 'Rückgängig';

  @override
  String get allergyWarningDismissed => 'Warnung für dieses Rezept ausgeblendet';

  @override
  String get scaleCustom => 'Benutzerdefiniert';

  @override
  String get scaleCustomTitle => 'Benutzerdefinierte Skalierung';

  @override
  String get scaleCustomHint => 'Beliebige Zahl eingeben (z.B. 0,75 für ¾, 2,5 für 2½)';

  @override
  String get scaleApply => 'Anwenden';

  @override
  String get addStep => 'Schritt hinzufügen';

  @override
  String get noInstructionsYet => 'Noch keine Anleitung';

  @override
  String get addFirstStep => 'Ersten Schritt hinzufügen';

  @override
  String get enterInstruction => 'Anleitung eingeben...';

  @override
  String get addStepImage => 'Schrittbild hinzufügen';

  @override
  String get removeStep => 'Schritt entfernen';

  @override
  String get plannerNoMeals => 'Keine Mahlzeiten geplant';

  @override
  String get plannerAddMealHint => 'Tippe auf + um eine Mahlzeit für diesen Tag hinzuzufügen';

  @override
  String plannerMealAdded(String recipe, String mealType) {
    return '$recipe zu $mealType hinzugefügt';
  }

  @override
  String get plannerShareMealPlan => 'Mahlzeitenplan teilen';

  @override
  String get plannerAddWeekToShopping => 'Woche zur Einkaufsliste hinzufügen';

  @override
  String get plannerClearWeek => 'Diese Woche löschen';

  @override
  String get plannerClearWeekConfirm => 'Dies entfernt alle geplanten Mahlzeiten für diese Woche. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get plannerWeekCleared => 'Woche gelöscht';

  @override
  String get plannerGoToToday => 'Zu heute gehen';

  @override
  String get plannerAddAnother => 'Weitere Mahlzeit hinzufügen';

  @override
  String get plannerSearchRecipes => 'Rezepte suchen...';

  @override
  String get mealTypeBreakfast => 'Frühstück';

  @override
  String get mealTypeLunch => 'Mittagessen';

  @override
  String get mealTypeDinner => 'Abendessen';

  @override
  String get mealTypeSnack => 'Snack';

  @override
  String shoppingItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Artikel',
      one: 'Artikel',
    );
    return '$count $_temp0';
  }

  @override
  String get shoppingBySection => 'Nach Abteilung';

  @override
  String get shoppingByRecipe => 'Nach Rezept';

  @override
  String get shoppingUngrouped => 'Ungruppiert';

  @override
  String get shoppingOrderOnline => 'Online bestellen';

  @override
  String get shoppingEditItem => 'Artikel bearbeiten';

  @override
  String get shoppingItemName => 'Artikelname';

  @override
  String get shoppingSelectCategory => 'Kategorie wählen';

  @override
  String get shoppingAddedManually => 'Manuell hinzugefügt';

  @override
  String get shoppingEmptyList => 'Deine Liste ist leer';

  @override
  String get shoppingEmptyHint => 'Tippe auf + um Artikel hinzuzufügen oder füge Zutaten aus deinen Rezepten hinzu';

  @override
  String get shoppingAddHint => 'Drücke Enter oder tippe auf Senden zum Hinzufügen, dann gib den nächsten Artikel ein';

  @override
  String get categoryDeli => 'Feinkost';

  @override
  String get categoryBreakfast => 'Frühstück & Müsli';

  @override
  String get categoryCanned => 'Konserven & Suppen';

  @override
  String get categoryCondiments => 'Gewürze, Soßen & Kräuter';

  @override
  String get categoryAlcohol => 'Bier, Wein & Spirituosen';

  @override
  String get categoryBaby => 'Baby';

  @override
  String get categoryBeauty => 'Kosmetik & Körperpflege';

  @override
  String get categoryHousehold => 'Haushaltswaren';

  @override
  String get categoryPet => 'Tierbedarf';

  @override
  String importFromPlatform(String platform) {
    return 'Importieren von $platform';
  }

  @override
  String importFromApp(String app) {
    return 'Importieren von $app';
  }

  @override
  String get helpAddingRecipes => 'Rezepte hinzufügen';

  @override
  String get helpAddingRecipesDesc => 'Tippe auf die + Taste in einem Kochbuch um ein Rezept hinzuzufügen. Du kannst von URLs importieren, Fotos machen oder manuell eingeben.';

  @override
  String get helpImporting => 'Aus Apps importieren';

  @override
  String get helpImportingDesc => 'Teile ein Rezept von Instagram, TikTok oder einer Website direkt mit Recipe Spellbook.';

  @override
  String get helpMealPlanning => 'Mahlzeitenplanung';

  @override
  String get helpMealPlanningDesc => 'Tippe auf den Mahlzeitenplan-Tab um deine Mahlzeiten für die Woche zu planen. Tippe auf + an einem Tag um Rezepte hinzuzufügen.';

  @override
  String get helpShopping => 'Einkaufslisten';

  @override
  String get helpShoppingDesc => 'Füge Zutaten aus Rezepten zu deiner Einkaufsliste hinzu. Artikel werden nach Abteilung sortiert.';

  @override
  String get helpSyncing => 'Synchronisierung';

  @override
  String get helpSyncingDesc => 'Cloud-Sync kommt bald! Deine Rezepte werden auf allen deinen Geräten synchronisiert.';

  @override
  String get helpContactUs => 'Kontakt';

  @override
  String get helpContactUsDesc => 'Hast du Fragen oder Feedback? Schreib uns an support@recipespellbook.com';

  @override
  String get navCommunity => 'Community';

  @override
  String get navComingSoon => 'Demnächst';

  @override
  String get mealPlanButton => 'Essensplan';

  @override
  String get groceriesButton => 'Einkaufen';

  @override
  String get shareButton => 'Teilen';

  @override
  String get scaleRecipeButton => 'Skalieren';

  @override
  String get convertUnitsButton => 'Umrechnen';

  @override
  String get allergyDismissTooltip => 'Warnung schließen';

  @override
  String get allergyDisablePrompt => 'Diese Warnung dauerhaft für dieses Rezept deaktivieren?';

  @override
  String get allergyDisabledForRecipe => 'Warnung für dieses Rezept deaktiviert';

  @override
  String get allergyRestoreWarnings => 'Warnungen wiederherstellen';

  @override
  String get recipeDuplicated => 'Rezept dupliziert';

  @override
  String get recipeDeleted => 'Rezept in den Papierkorb verschoben';

  @override
  String get deleteRecipeTitle => 'Rezept löschen';

  @override
  String get deleteRecipeConfirm => 'Möchten Sie dieses Rezept wirklich löschen? Es wird in den Papierkorb verschoben.';

  @override
  String get addToShoppingListTitle => 'Zur Einkaufsliste hinzufügen';

  @override
  String get viewList => 'Liste anzeigen';

  @override
  String get selectItems => 'Artikel auswählen';

  @override
  String addToListCount(int count) {
    return '$count Artikel hinzufügen';
  }

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get save => 'Speichern';

  @override
  String get restore => 'Wiederherstellen';

  @override
  String get unselectAll => 'Auswahl aufheben';

  @override
  String get deleteStep => 'Schritt löschen';

  @override
  String get deleteSteps => 'Schritte löschen';

  @override
  String get deleteStepConfirm => 'Diesen Schritt löschen?';

  @override
  String deleteStepsConfirm(int count) {
    return '$count Schritte löschen?';
  }

  @override
  String stepSelected(int count) {
    return '$count ausgewählt';
  }

  @override
  String get selectAllSteps => 'Alle auswählen';

  @override
  String get gradientBased => 'Farbverlauf';

  @override
  String get gradientBasedDescription => 'Farbverlauf basierend auf deinem Theme';

  @override
  String get startCooking => 'Kochen starten';

  @override
  String get fontSizeLabel => 'Schriftgröße';

  @override
  String krogerLoginDenied(String error) {
    return 'Kroger-Anmeldung abgelehnt: $error';
  }

  @override
  String get krogerNoAuthCode => 'Kein Autorisierungscode von Kroger erhalten.';

  @override
  String get krogerConnected => 'Kroger verbunden! Du kannst jetzt Artikel direkt in deinen Warenkorb legen.';

  @override
  String get krogerConnectFailed => 'Verbindung mit Kroger fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get krogerConnecting => 'Verbindung mit Kroger wird hergestellt…';

  @override
  String get krogerExchanging => 'Autorisierung wird ausgetauscht...';

  @override
  String get krogerConnectedTitle => 'Verbunden!';

  @override
  String get krogerConnectionFailed => 'Verbindung fehlgeschlagen';

  @override
  String get goToShoppingList => 'Zur Einkaufsliste';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get skipForNow => 'Jetzt überspringen';

  @override
  String get skipDuplicates => 'Duplikate überspringen';

  @override
  String get deselectAll => 'Alle abwählen';

  @override
  String get duplicate => 'Duplikat';

  @override
  String recipesImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rezepte',
      one: 'Rezept',
    );
    return '$count $_temp0 importiert';
  }

  @override
  String importCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rezepte',
      one: 'Rezept',
    );
    return '$count $_temp0 importieren';
  }

  @override
  String get productNotFound => 'Produkt nicht gefunden';

  @override
  String barcodeNotFound(String barcode) {
    return 'Kein Produkt für Barcode gefunden:\n$barcode';
  }

  @override
  String get manualEntryHint => 'Du kannst den Produktnamen manuell eingeben.';

  @override
  String get scanAgain => 'Erneut scannen';

  @override
  String get enterManually => 'Manuell eingeben';

  @override
  String get enterProductName => 'Produktname eingeben';

  @override
  String get productName => 'Produktname';

  @override
  String get scanBarcode => 'Barcode scannen';

  @override
  String get lookingUpProduct => 'Produkt wird gesucht...';

  @override
  String get pointCameraBarcode => 'Richte die Kamera auf einen Produkt-Barcode';

  @override
  String get unknownProduct => 'Unbekanntes Produkt';

  @override
  String get nutritionPer100g => 'Nährwerte (pro 100g)';

  @override
  String get findRecipesWithThis => 'Rezepte damit finden';

  @override
  String get scanAnother => 'Weiteren scannen';

  @override
  String get exportFormat => 'Exportformat';

  @override
  String get gotIt => 'Verstanden';

  @override
  String get calendar => 'Kalender';

  @override
  String get today => 'Heute';

  @override
  String get shareMealPlan => 'Essensplan teilen';

  @override
  String get addWeekToShoppingList => 'Woche zur Einkaufsliste hinzufügen';

  @override
  String get clearThisWeek => 'Diese Woche löschen?';

  @override
  String get clearWeekWarning => 'Dies entfernt alle geplanten Mahlzeiten für diese Woche. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get goToToday => 'Zu heute springen';

  @override
  String get addAnotherMeal => 'Weitere Mahlzeit hinzufügen';

  @override
  String get meal => 'Mahlzeit';

  @override
  String get noMealsPlanned => 'Keine Mahlzeiten geplant';

  @override
  String get tapToAddMeal => 'Tippe auf + um eine Mahlzeit für diesen Tag hinzuzufügen';

  @override
  String get addMeal => 'Mahlzeit hinzufügen';

  @override
  String addToDay(String dayName) {
    return 'Zum $dayName hinzufügen';
  }

  @override
  String get searchRecipes => 'Rezepte suchen...';

  @override
  String get noRecipesFound => 'Keine Rezepte gefunden';

  @override
  String get exitShoppingListGenerator => 'Einkaufslisten-Generator verlassen?';

  @override
  String get actionExit => 'Verlassen';

  @override
  String get shoppingListGenerator => 'Einkaufslisten-Generator';

  @override
  String reviewAndAdd(int count) {
    return 'Überprüfen & hinzufügen ($count Artikel)';
  }

  @override
  String addItemsToList(int count) {
    return '$count Artikel zur Liste hinzufügen';
  }

  @override
  String addedItemsToShoppingList(int count) {
    return '$count Artikel zur Einkaufsliste hinzugefügt';
  }

  @override
  String get createNewList => 'Neue Liste erstellen';

  @override
  String get listName => 'Listenname';

  @override
  String get manage => 'Verwalten';

  @override
  String get myPantry => 'Meine Vorratskammer';

  @override
  String get itemsAlwaysOnHand => 'Artikel, die du immer vorrätig hast';

  @override
  String get whatToDelete => 'Was möchtest du löschen?';

  @override
  String get localData => 'Lokale Daten';

  @override
  String get localDataDesc => 'Rezepte, Kochbücher, Essenspläne, Einkaufslisten auf diesem Gerät';

  @override
  String get allData => 'Alle Daten';

  @override
  String get allDataDesc => 'Lokale Daten und Einstellungen — kompletter Neustart';

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
    return 'Dies wird $scope dauerhaft löschen. Dies kann nicht rückgängig gemacht werden.';
  }

  @override
  String get dataResetComplete => 'Daten zurückgesetzt';

  @override
  String get noThanks => 'Nein, danke';

  @override
  String importFailed(String error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get yesAddThem => 'Ja, hinzufügen';

  @override
  String get nutritionDisplay => 'Nährwertanzeige';

  @override
  String get nutritionDisplaySubtitle => 'Diagrammstil, sichtbare Nährstoffe';

  @override
  String get storeIntegrations => 'Shop-Integrationen';

  @override
  String get instacart => 'Instacart';

  @override
  String get kroger => 'Kroger';

  @override
  String get connected => 'Verbunden';

  @override
  String get setCustomApiKey => 'Eigenen API-Schlüssel festlegen';

  @override
  String get useOwnInstacartKey => 'Verwende deinen eigenen Instacart Connect Schlüssel';

  @override
  String get instacartApiKey => 'Instacart API-Schlüssel';

  @override
  String get resetToDefaultKey => 'Standardschlüssel wiederherstellen';

  @override
  String get removeCustomKey => 'Eigenen Schlüssel entfernen, Standard verwenden';

  @override
  String get signInToKroger => 'Bei Kroger anmelden';

  @override
  String get connectToAddItems => 'Verbinde dich, um Artikel in deinen Warenkorb zu legen';

  @override
  String get setPreferredStore => 'Bevorzugten Markt festlegen';

  @override
  String get searchByZipCode => 'Nach Postleitzahl suchen';

  @override
  String get disconnect => 'Trennen';

  @override
  String get apiKeySaved => 'API-Schlüssel gespeichert';

  @override
  String get findYourKrogerStore => 'Finde deinen Kroger-Markt';

  @override
  String get enterZipCode => 'Postleitzahl eingeben';

  @override
  String storeSet(String name) {
    return 'Markt festgelegt: $name';
  }

  @override
  String get menuImportSubtitle => 'Instagram, TikTok, Webseiten...';

  @override
  String get menuSyncToMobile => 'Mit Handy synchronisieren';

  @override
  String get menuSyncToDesktop => 'Mit Desktop synchronisieren';

  @override
  String get menuTransferToPhone => 'Daten auf dein Handy übertragen';

  @override
  String get menuTransferToDevice => 'Daten auf ein anderes Gerät übertragen';

  @override
  String get menuProfile => 'Profil';

  @override
  String get menuProfileSubtitle => 'Statistiken und Fortschritt anzeigen';

  @override
  String get menuAchievementsSubtitle => 'Belohnungen freischalten';

  @override
  String get menuCosmetics => 'Kosmetik';

  @override
  String get menuCosmeticsSubtitle => 'Aussehen anpassen';

  @override
  String get menuLeaderboardsSubtitle => 'Mit anderen messen';

  @override
  String get menuBossBattles => 'Bosskämpfe';

  @override
  String get menuBossBattlesSubtitle => 'Epische Koch-Herausforderungen';

  @override
  String get menuImportRecipes => 'Rezepte importieren';

  @override
  String get menuHelpSupport => 'Hilfe & Support';

  @override
  String menuAppVersion(String version) {
    return 'Recipe Spellbook v$version';
  }

  @override
  String get menuShareApp => 'Recipe Spellbook teilen';

  @override
  String get menuShareSubtitle => 'Lade deine Freunde und Familie zum gemeinsamen Kochen ein!';

  @override
  String get menuShareMessage => 'Schau dir Recipe Spellbook an — die beste Rezepte-App! https://recipespellbook.app/get';

  @override
  String get signIn => 'Anmelden';

  @override
  String get helpFromWebsite => 'Von einer Webseite';

  @override
  String get helpFromWebsiteDesc => 'Tippe + in einem Kochbuch und füge eine Rezept-URL ein. Funktioniert mit den meisten Rezeptseiten.';

  @override
  String get helpFromSocial => 'Von Instagram oder TikTok';

  @override
  String get helpFromSocialDesc => 'Kopiere den Link eines Rezept-Posts, tippe + und füge ihn ein.';

  @override
  String get helpFromPhoto => 'Von einem Foto';

  @override
  String get helpFromPhotoDesc => 'Fotografiere ein Rezept. Tippe + und wähle Bild zum Scannen mit OCR.';

  @override
  String get helpFromPdf => 'Von einer PDF';

  @override
  String get helpFromPdfDesc => 'Tippe + und wähle Datei, um ein PDF-Rezept zu importieren.';

  @override
  String get helpFromText => 'Aus Text';

  @override
  String get helpFromTextDesc => 'Kopiere Rezepttext, tippe + und Einfügen.';

  @override
  String get helpFromPaprika => 'Von Paprika';

  @override
  String get helpFromPaprikaDesc => 'In Paprika: Exportieren → \"HTML\"-Format. Dann tippe + und importiere die Datei.';

  @override
  String get helpFromOtherApps => 'Von anderen Apps';

  @override
  String get helpFromOtherAppsDesc => 'Die meisten Rezepte-Apps exportieren als HTML oder Text. Exportiere und importiere hier mit +.';

  @override
  String get helpCloudSync => 'Cloud-Synchronisierung';

  @override
  String get helpCloudSyncDesc => 'Abonniere Cloud Sync, um deine Rezepte auf allen Geräten synchron zu halten.';

  @override
  String get accountTitle => 'Konto';

  @override
  String get accountSubscription => 'Abonnement';

  @override
  String get accountManageSubscription => 'Abonnement verwalten';

  @override
  String get accountCloudSync => 'Cloud-Synchronisierung';

  @override
  String get accountSyncNow => 'Jetzt synchronisieren';

  @override
  String get accountIntegrations => 'Integrationen';

  @override
  String get accountDangerZone => 'Gefahrenzone';

  @override
  String get purchasesRestored => 'Käufe erfolgreich wiederhergestellt!';

  @override
  String get noPurchasesFound => 'Keine früheren Käufe gefunden.';

  @override
  String get restoreFailed => 'Wiederherstellung fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String get restorePurchasesLong => 'Käufe wiederherstellen';

  @override
  String get cancelled => 'Gekündigt';

  @override
  String get accessUntil => 'Zugang bis';

  @override
  String get renews => 'Verlängerung';

  @override
  String get plan => 'Plan';

  @override
  String get upgradeDescription => 'Schalte Cloud-Sync, Smart-Import und mehr frei.';

  @override
  String get syncDescription => 'Halte deine Rezepte geräteübergreifend synchron.';

  @override
  String get sync => 'Synchronisieren';

  @override
  String get signInToSync => 'Anmelden zum Synchronisieren';

  @override
  String get signInSyncDesc => 'Sichere deine Rezepte, synchronisiere zwischen Geräten und schalte Premium-Funktionen frei.';

  @override
  String get continueWithGoogle => 'Weiter mit Google';

  @override
  String get continueWithApple => 'Weiter mit Apple';

  @override
  String get signOut => 'Abmelden';

  @override
  String get signOutQuestion => 'Abmelden?';

  @override
  String get signOutDesc => 'Deine Rezepte bleiben auf diesem Gerät. Du kannst dich jederzeit wieder anmelden.';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get deleteAccountQuestion => 'Konto löschen?';

  @override
  String get deleteAccountDesc => 'Dies löscht dein Konto und alle synchronisierten Daten dauerhaft.\n\nLokal gespeicherte Rezepte werden NICHT gelöscht.';

  @override
  String get deletePermanently => 'Dauerhaft löschen';

  @override
  String get deleteAccountFailed => 'Konto konnte nicht gelöscht werden. Bitte versuche es erneut.';

  @override
  String get signInToApp => 'Bei Recipe Spellbook anmelden';

  @override
  String get signInSyncLong => 'Synchronisiere Rezepte, schalte Cloud-Backup frei und greife auf Pro-Funktionen zu.';

  @override
  String get recipesStayOnDevice => 'Deine Rezepte bleiben auch ohne Konto auf diesem Gerät.';

  @override
  String get upgradeToPro => 'Auf Pro upgraden';

  @override
  String subscriptionDot(String tier) {
    return 'Abo · $tier';
  }

  @override
  String get affluentLabsPro => 'Affluent Labs Pro';

  @override
  String cancelledAccessUntil(String date) {
    return 'Gekündigt — Zugang bis $date';
  }

  @override
  String get lifetimeNeverExpires => 'Lebenslang — läuft nie ab';

  @override
  String renewsDate(String date) {
    return 'Verlängerung $date';
  }

  @override
  String get manageSubscription => 'Abo verwalten';

  @override
  String get tierPremium => 'Premium';

  @override
  String get tierStandard => 'Standard';

  @override
  String get tierBasic => 'Basis';

  @override
  String get tierFree => 'Kostenlos';

  @override
  String tierPlan(String tier) {
    return '$tier-Plan';
  }

  @override
  String get upgradeArrow => 'Upgrade →';

  @override
  String get syncNow => 'Jetzt synchronisieren';

  @override
  String get syncing => 'Synchronisiere...';

  @override
  String lastSynced(String time) {
    return 'Letzte Synchronisierung $time';
  }

  @override
  String get notYetSynced => 'Noch nicht synchronisiert';

  @override
  String get cloudSyncSection => 'CLOUD-SYNC';

  @override
  String get noRecipesPlannedThisWeek => 'Keine Rezepte für diese Woche geplant';

  @override
  String get todayBadge => 'HEUTE';

  @override
  String get noCourseAssigned => 'Kein Gang zugewiesen';

  @override
  String get uncategorized => 'Unkategorisiert';

  @override
  String get allRecipesHaveCourse => 'Alle Rezepte haben einen Gang!';

  @override
  String get allRecipesCategorized => 'Alle Rezepte sind kategorisiert!';

  @override
  String get greatJobOrganizing => 'Gut gemacht beim Organisieren deiner Rezepte!';

  @override
  String countOfTotal(int count, int total) {
    return '$count von $total';
  }

  @override
  String get tapToAssignCourse => 'Tippen, um einen Gang zuzuweisen';

  @override
  String get tapToAssignCategory => 'Tippen, um eine Kategorie zuzuweisen';

  @override
  String deleteCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rezepte',
      one: 'Rezept',
    );
    return '$count $_temp0 löschen?';
  }

  @override
  String countRecipesMovedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rezepte',
      one: 'Rezept',
    );
    return '$count $_temp0 in den Papierkorb verschoben';
  }

  @override
  String get setCourse => 'Gang festlegen';

  @override
  String get setCategory => 'Kategorie festlegen';

  @override
  String courseSetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rezepte',
      one: 'Rezept',
    );
    return 'Gang festgelegt für $count $_temp0';
  }

  @override
  String categorySetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rezepte',
      one: 'Rezept',
    );
    return 'Kategorie festgelegt für $count $_temp0';
  }

  @override
  String countRecipesFavorited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rezepte',
      one: 'Rezept',
    );
    return '$count $_temp0 als Favorit markiert';
  }

  @override
  String get bulkCourse => 'Gang';

  @override
  String get bulkCategory => 'Kategorie';

  @override
  String get bulkFavorite => 'Favorit';

  @override
  String get aiImportTitle => 'Von KI importieren';

  @override
  String get aiCopyPrompt => 'Prompt kopieren';

  @override
  String get aiCopyPromptSubtitle => 'Füge dies in ChatGPT, Claude, Gemini oder eine andere KI zusammen mit deinem Rezept ein.';

  @override
  String get aiCopied => 'Kopiert!';

  @override
  String get aiCopyToClipboard => 'Prompt in Zwischenablage kopieren';

  @override
  String get aiPreviewPrompt => 'Prompt-Vorschau';

  @override
  String get aiPasteOutput => 'KI-Ausgabe einfügen';

  @override
  String get aiPasteSubtitle => 'Füge das JSON der KI ein oder importiere eine .json-Datei.';

  @override
  String get aiPasteFirst => 'Erst JSON einfügen oder laden.';

  @override
  String aiFailedReadFile(String error) {
    return 'Datei konnte nicht gelesen werden: $error';
  }

  @override
  String get aiUntitledRecipe => 'Unbenanntes Rezept';

  @override
  String get aiImporting => 'Importiere...';

  @override
  String get aiImportToCookbook => 'In Kochbuch importieren';

  @override
  String get aiImportSuccess => 'Rezept erfolgreich importiert!';

  @override
  String get aiPreviewImport => 'Vorschau & Importieren';

  @override
  String get aiPromptCopied => 'Prompt kopiert! Füge ihn in eine KI mit deinem Rezept ein.';

  @override
  String get aiLoadJsonFile => '.json-Datei laden';

  @override
  String get aiPaste => 'Einfügen';

  @override
  String get aiTipsTitle => 'Tipps';

  @override
  String get aiTip1 => 'Funktioniert mit ChatGPT, Claude, Gemini, Copilot oder jeder KI';

  @override
  String get aiTip2 => 'Du kannst auch ein Foto eines Rezepts mit dem Prompt einfügen';

  @override
  String get aiTip3 => 'Die KI konvertiert handgeschriebene, gedruckte oder Web-Rezepte';

  @override
  String get aiTip4 => 'Wenn das JSON Fehler hat, bitte die KI es zu korrigieren';

  @override
  String aiServingsLabel(String count) {
    return '$count Portionen';
  }

  @override
  String aiPrepLabel(String minutes) {
    return '${minutes}m Vorbereitung';
  }

  @override
  String aiCookLabel(String minutes) {
    return '${minutes}m Kochen';
  }

  @override
  String aiIngredientsCount(int count) {
    return 'Zutaten ($count)';
  }

  @override
  String aiStepsCount(int count) {
    return 'Schritte ($count)';
  }

  @override
  String get restoreAllWarnings => 'Alle Warnungen wiederherstellen';

  @override
  String get warningsRestoredForRecipe => 'Warnungen für Rezept wiederhergestellt';

  @override
  String get restoreAllWarningsQuestion => 'Alle Warnungen wiederherstellen?';

  @override
  String get restoreAll => 'Alle wiederherstellen';

  @override
  String get allWarningsRestored => 'Alle Warnungen wiederhergestellt';

  @override
  String dismissedWarnings(int count) {
    return '$count ausgeblendet';
  }

  @override
  String get restoringPurchases => 'Käufe werden wiederhergestellt...';

  @override
  String get restorePurchases => 'Wiederherstellen';

  @override
  String get compareAllPlans => 'Alle Pläne vergleichen';

  @override
  String get oneTimeTab => 'Einmalig';

  @override
  String get subscriptionTab => 'Abo';

  @override
  String get payOnceKeepForever => 'Einmal zahlen, für immer behalten';

  @override
  String get cloudSyncFreeTrial => 'Try free for 1 week';

  @override
  String get subscribeCloudSyncMonthlyTrialCta => 'Start free trial — then \$2.99/mo';

  @override
  String get subscribeCloudSyncYearlyTrialCta => 'Start free trial — then \$29.99/yr';

  @override
  String get cloudSyncFeature => 'Cloud-Sync';

  @override
  String get cloudSyncFamilyFeature => 'Cloud-Sync+';

  @override
  String get unableToLoadProducts => 'Produkte konnten nicht geladen werden. Erneut versuchen.';

  @override
  String get noOfferingsAvailable => 'Keine Angebote verfügbar. Später erneut versuchen.';

  @override
  String purchaseFailed(String error) {
    return 'Kauf fehlgeschlagen: $error';
  }

  @override
  String get hintProductExample => 'z.B. Bio-Nudelsauce';

  @override
  String get previewPhoto => 'Fotovorschau';

  @override
  String get retake => 'Neu aufnehmen';

  @override
  String get usePhoto => 'Foto verwenden';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get chooseFromGallery => 'Aus Galerie wählen';

  @override
  String get removeImage => 'Bild entfernen';

  @override
  String get tipsPlaceholder => 'Tipps, Variationen, Lagerung...';

  @override
  String get totalCalories => 'Gesamt kcal';

  @override
  String get caloriesPerServing => 'kcal/Portion';

  @override
  String get totalNutrition => 'Gesamt';

  @override
  String get linkRecipe => 'Rezept verknüpfen';

  @override
  String get addIngredient => 'Zutat hinzufügen';

  @override
  String get searchRecipesToLink => 'Rezepte zum Verknüpfen suchen...';

  @override
  String linkToIngredient(String name) {
    return 'Mit \"$name\" verknüpfen';
  }

  @override
  String errorSavingRecipe(String error) {
    return 'Fehler beim Speichern: $error';
  }

  @override
  String deleteSelectedCount(int count) {
    return '$count löschen';
  }

  @override
  String get takeAPhoto => 'Ein Foto machen';

  @override
  String get defaultLabel => 'Standard';

  @override
  String get scaleRecipe => 'Rezept skalieren';

  @override
  String get scaleHint => 'z.B. 2,5';

  @override
  String get badgePinned => 'Angepinnt';

  @override
  String get badgeRecentlyViewed => 'Zuletzt angesehen';

  @override
  String get displayOptions => 'Anzeigeoptionen';

  @override
  String get showMealPlan => 'Essensplan anzeigen';

  @override
  String get showMealPlanSubtitle => 'Heutige geplante Rezepte anzeigen';

  @override
  String get showPinnedRecipes => 'Angepinnte Rezepte anzeigen';

  @override
  String get showPinnedSubtitle => 'Angepinnte Rezepte anzeigen';

  @override
  String get showRecentHistory => 'Verlauf anzeigen';

  @override
  String get showRecentSubtitle => 'Kürzlich angesehene Rezepte anzeigen';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get measurementsUS => 'Tassen, Esslöffel, Unzen, °F';

  @override
  String get measurementsMetric => 'Milliliter, Gramm, °C';

  @override
  String defaultRecipesImported(int count) {
    return '$count Standardrezepte importiert!';
  }

  @override
  String get shoppingListGeneratorTitle => 'Einkaufslisten-Generator';

  @override
  String get exitShoppingListGeneratorQuestion => 'Generator verlassen?';

  @override
  String reviewAndAddItems(int count) {
    return 'Prüfen & Hinzufügen ($count Artikel)';
  }

  @override
  String addedTotalItemsToList(int count) {
    return '$count Artikel zur Einkaufsliste hinzugefügt';
  }

  @override
  String scaleMultiplier(String scale) {
    return '${scale}x';
  }

  @override
  String get printIngredients => 'Zutaten';

  @override
  String get printInstructions => 'Zubereitung';

  @override
  String get printNotes => 'Notizen';

  @override
  String printPrep(int minutes) {
    return 'Vorbereitung: $minutes Min.';
  }

  @override
  String printCook(int minutes) {
    return 'Kochen: $minutes Min.';
  }

  @override
  String get printFooter => 'Gedruckt aus Recipe Spellbook';

  @override
  String printPage(int current, int total) {
    return 'Seite $current von $total';
  }

  @override
  String get menuNavigation => 'NAVIGATION';

  @override
  String get menuImport => 'IMPORTIEREN';

  @override
  String get menuKitchenBuddyMode => 'RPG-MODUS';

  @override
  String get menuSocial => 'SOZIALES';

  @override
  String get menuApp => 'APP';

  @override
  String get historyCount => 'Verlauf-Anzahl';

  @override
  String get historyCountSubtitle => 'Maximale Anzahl der angezeigten letzten Rezepte';

  @override
  String get restoreAllWarningsDesc => 'Dadurch werden Allergie-Warnungen für alle Rezepte wieder aktiviert.';

  @override
  String get signInToContinue => 'Anmelden um fortzufahren';

  @override
  String get signInForPurchaseDesc => 'Vor dem Kauf ist ein Konto erforderlich, damit dein Abo geräteübergreifend verknüpft bleibt.';

  @override
  String get menuAchievements => 'Erfolge';

  @override
  String get menuLeaderboards => 'Bestenlisten';

  @override
  String get requiresPremium => 'Premium erforderlich';

  @override
  String deleteCount(int count) {
    return '$count löschen';
  }

  @override
  String get tapToSelectPhoto => 'Tippen, um aus Galerie oder Kamera auszuwählen';

  @override
  String get rating => 'Bewertung';

  @override
  String get usUnits => 'Cups, Esslöffel, Unzen, °F';

  @override
  String get metricUnits => 'Milliliter, Gramm, °C';

  @override
  String selectedCount(int count) {
    return '$count ausgewählt';
  }

  @override
  String deleteRecipesConfirm(int count) {
    return '$count Rezept(e) löschen?';
  }

  @override
  String courseSetForRecipes(int count) {
    return 'Gang für $count Rezept(e) festgelegt';
  }

  @override
  String get recipeImportedSuccess => 'Rezept erfolgreich importiert!';

  @override
  String get promptCopied => 'Prompt kopiert! Füge ihn in eine KI mit deinem Rezept ein.';

  @override
  String get importFromAI => 'Aus KI importieren';

  @override
  String get paste => 'Einfügen';

  @override
  String get previewAndImport => 'Vorschau & Importieren';

  @override
  String get signInDescription => 'Sichere deine Rezepte, synchronisiere zwischen Geräten und schalte Premium-Funktionen frei.';

  @override
  String get signOutConfirmTitle => 'Abmelden?';

  @override
  String get signOutConfirmMessage => 'Deine Rezepte bleiben auf diesem Gerät. Du kannst dich jederzeit wieder anmelden, um die Synchronisierung zu aktivieren.';

  @override
  String get deleteAccountConfirmTitle => 'Konto löschen?';

  @override
  String get deleteAccountConfirmMessage => 'Dadurch werden dein Konto und alle synchronisierten Daten dauerhaft von unseren Servern gelöscht.\n\nLokal auf diesem Gerät gespeicherte Rezepte werden NICHT gelöscht.';

  @override
  String planLabel(String label) {
    return '$label-Abo';
  }

  @override
  String permanentlyDeleteWarning(String scope) {
    return 'Dies wird $scope dauerhaft löschen. Dies kann nicht rückgängig gemacht werden.';
  }

  @override
  String recipesMovedToTrash(int count) {
    return 'Rezepte werden in den Papierkorb verschoben. Du kannst sie später wiederherstellen.';
  }

  @override
  String recipesFavorited(int count) {
    return '$count Rezept(e) favorisiert';
  }

  @override
  String get upgradeRecipeSpellbook => 'Recipe Spellbook upgraden';

  @override
  String get choosePlanSubtitle => 'Wähle den Plan, der zu deiner Küche passt';

  @override
  String get premiumInfoNotice => 'Premium ist ein einmaliger Kauf, der dein kostenloses Erlebnis verbessert. Familienfreigabe und erweiterte Cloud-Funktionen sind nicht enthalten — siehe Abonnements.';

  @override
  String get bestValue => 'BESTER WERT';

  @override
  String get billedMonthly => 'Monatlich abgerechnet';

  @override
  String get save16Yearly => 'Spare 16% — nur 2,50 \$/Monat';

  @override
  String get save16Badge => 'SPARE 16%';

  @override
  String get save17Yearly => 'Spare 17% — nur 4,17 \$/Monat';

  @override
  String get subscriptionsIncludePremium => 'Alle Abonnements beinhalten alles aus Premium.';

  @override
  String get monthly => 'Monatlich';

  @override
  String get yearly => 'Jährlich';

  @override
  String get purchasePremiumCta => 'Premium kaufen — 6,99 \$';

  @override
  String get subscribeCloudSyncMonthlyCta => 'Abonnieren — 2,99 \$/Monat';

  @override
  String get subscribeCloudSyncYearlyCta => 'Abonnieren — 29,99 \$/Jahr';

  @override
  String get subscribeCloudSyncPlusMonthlyCta => 'Abonnieren — 4,99 \$/Monat';

  @override
  String get subscribeCloudSyncPlusYearlyCta => 'Abonnieren — 49,99 \$/Jahr';

  @override
  String get signInRequiredBeforePurchase => 'Anmeldung vor dem Kauf erforderlich';

  @override
  String get terms => 'AGB';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get comparePlans => 'Pläne vergleichen';

  @override
  String get featureCloudSyncPersonal => 'Cloud-Sync (persönlich)';

  @override
  String get featurePhotosOnSteps => 'Fotos bei Schritten';

  @override
  String get featureCloudStorageLimited => 'Cloud storage — Limited';

  @override
  String get featureFamilySharing5 => 'Familienfreigabe (5 Mitglieder)';

  @override
  String get featureCloudStorage => 'Cloud storage';

  @override
  String get featureSharedLists => 'Geteilte Einkaufslisten';

  @override
  String get featureSharedCookbooks => 'Geteilte Kochbücher';

  @override
  String get featureSharedMealPlan => 'Geteilte Essensplanung';

  @override
  String get featureAutoBackups => 'Automatic backups';

  @override
  String get featureFamilySharing10 => 'Familienfreigabe (10 Mitglieder)';

  @override
  String get featurePrioritySync => 'Prioritäts-Sync-Leistung';

  @override
  String get featureFutureAdvanced => 'Zukünftige erweiterte Funktionen inklusive';

  @override
  String get tierCloudSync => 'Cloud\nSync';

  @override
  String get tierCloudSyncPlus => 'Cloud\nSync+';

  @override
  String get comparePrice => 'Preis';

  @override
  String get priceFree => '0 \$';

  @override
  String get pricePremium => '6,99 \$\neinmalig';

  @override
  String get priceCloudSync => '2,99 \$\n/Monat';

  @override
  String get priceCloudSyncPlus => '4,99 \$\n/Monat';

  @override
  String get compareDeviceTransfer => 'Geräteübertragung';

  @override
  String get qrCode => 'QR-Code';

  @override
  String get cloud => 'Cloud';

  @override
  String get comparePhotoStorage => 'Fotospeicher';

  @override
  String get compareStepPhotos => 'Schrittfotos';

  @override
  String get compareFamilySharing => 'Familienfreigabe';

  @override
  String get compareSharedLists => 'Geteilte Listen';

  @override
  String get compareSharedCookbooks => 'Geteilte Kochbücher';

  @override
  String get compareSharedMealPlan => 'Geteilter Essensplan';

  @override
  String get compareBackups => 'Backups';

  @override
  String get compareCloudStorage => 'Cloud-Speicher';

  @override
  String get compareCloudStorageBasic => 'Basis';

  @override
  String get compareCloudStorageStandard => 'Standard';

  @override
  String get compareCloudStorageExtended => 'Erweitert';

  @override
  String get printOf => 'von';

  @override
  String get printRecipe => 'Drucken';

  @override
  String get stackedLayout => 'Gestapeltes Layout';

  @override
  String get tabbedLayout => 'Tab-Layout';

  @override
  String get printLabelIngredients => 'Zutaten';

  @override
  String get printLabelInstructions => 'Anleitung';

  @override
  String get printLabelNotes => 'Notizen';

  @override
  String get printLabelPrep => 'Vorbereitung';

  @override
  String get printLabelCook => 'Kochen';

  @override
  String get printLabelFooter => 'Gedruckt aus Recipe Spellbook';

  @override
  String get printLabelPage => 'Seite';

  @override
  String get printLabelOf => 'von';

  @override
  String get smallerText => 'Kleinere Schrift';

  @override
  String get largerText => 'Größere Schrift';

  @override
  String get textSize => 'Textgröße';

  @override
  String get ingredientPreview => 'Zutatenvorschau';

  @override
  String get resetToDefault => 'Auf Standard zurücksetzen';

  @override
  String get learnMore => 'Mehr erfahren';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get upgrade => 'Upgraden';

  @override
  String get cookingMode => 'Kochmodus';

  @override
  String get mealTypeDessert => 'Dessert';

  @override
  String get noContentToSave => 'Kein Inhalt zum Speichern';

  @override
  String get recipeSaved => 'Rezept gespeichert!';

  @override
  String get qrScanningMobileOnly => 'QR-Scannen ist nur auf Mobilgeräten verfügbar.';

  @override
  String get communityComingSoon => 'Community-Funktionen kommen in einem zukünftigen Update!';

  @override
  String somethingWentWrong(String error) {
    return 'Etwas ist schiefgelaufen: $error';
  }

  @override
  String starterRecipesAdded(int count) {
    return '$count Starterrezepte hinzugefügt! 🎉';
  }

  @override
  String get enterAtLeastOneNutrient => 'Geben Sie mindestens Kalorien oder einen Makronährstoff ein';

  @override
  String addedToMealPlan(String mealType, String date) {
    return 'Zu $mealType am $date hinzugefügt';
  }

  @override
  String get noItemsFoundInText => 'Keine Einträge im Text gefunden';

  @override
  String get noTextFoundInImage => 'Kein Text im Bild gefunden';

  @override
  String get addDayToShoppingList => 'Tag zur Einkaufsliste hinzufügen';

  @override
  String get sendDayToShoppingList => 'Tag an Einkaufsliste senden';

  @override
  String get removeMeal => 'Mahlzeit entfernen';

  @override
  String removeMealConfirm(String recipeName) {
    return '$recipeName von diesem Tag entfernen?';
  }

  @override
  String get actionRemove => 'Entfernen';

  @override
  String get plannerMealRemoved => 'Mahlzeit entfernt';

  @override
  String get weekStartsOn => 'Woche beginnt am';

  @override
  String get monday => 'Montag';

  @override
  String get saturday => 'Samstag';

  @override
  String get sunday => 'Sonntag';

  @override
  String get ingredientHeader => 'Überschrift';

  @override
  String get ingredientHeaderHint => 'z.B., Für die Soße';

  @override
  String get settingsWeekStartDay => 'Woche beginnt am';

  @override
  String get settingsSurpriseMe => '\'Überrasch mich\'-Karte anzeigen';

  @override
  String get settingsSurpriseMeSubtitle => 'Rezeptvorschlagskarte auf dem Startbildschirm anzeigen';

  @override
  String get settingsNotifications => 'Benachrichtigungen';

  @override
  String get settingsNotifCooking => 'Kocherinnerungen';

  @override
  String get settingsNotifCookingSubtitle => 'Essensplan-Hinweise und Kocherinnerungen';

  @override
  String get settingsNotifCommunity => 'Community-Updates';

  @override
  String get settingsNotifCommunitySubtitle => 'Downloads, Bewertungen und Kommentare zu deinen Rezepten';

  @override
  String get settingsNotifAchievements => 'Erfolge';

  @override
  String get settingsNotifAchievementsSubtitle => 'Freigeschaltete Erfolge und Meilenstein-Hinweise';

  @override
  String get settingsNotifBuddy => 'Quest-Erinnerungen';

  @override
  String get settingsNotifBuddySubtitle => 'Taegliche Quest-Resets und XP-Erinnerungen';

  @override
  String get settingsNotifManagePreferences => 'Benachrichtigungseinstellungen verwalten';

  @override
  String get settingsNotifNewDownloads => 'Neue Downloads';

  @override
  String get settingsNotifNewDownloadsSubtitle => 'Wenn jemand dein veröffentlichtes Rezept herunterlädt';

  @override
  String get settingsNotifRatingUpdates => 'Bewertungsaktualisierungen';

  @override
  String get settingsNotifRatingUpdatesSubtitle => 'Wenn dein veröffentlichtes Rezept eine neue Bewertung erhält';

  @override
  String get settingsNotifComments => 'Kommentare';

  @override
  String get settingsNotifCommentsSubtitle => 'Wenn jemand dein Rezept kommentiert';

  @override
  String get settingsNotifSyncNote => 'Benachrichtigungseinstellungen werden mit deinem Konto synchronisiert.';

  @override
  String get tuesday => 'Dienstag';

  @override
  String get wednesday => 'Mittwoch';

  @override
  String get thursday => 'Donnerstag';

  @override
  String get friday => 'Freitag';

  @override
  String shoppingAddedToList(int count, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Artikel hinzugefügt',
      one: 'Artikel hinzugefügt',
    );
    return '$count $_temp0 zu \"$listName\"';
  }

  @override
  String shoppingAddedAndCombined(int added, int combined, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: 'Artikel hinzugefügt',
      one: 'Artikel hinzugefügt',
    );
    return '$added $_temp0 zu \"$listName\", $combined zusammengefasst';
  }

  @override
  String shoppingItemsUpdated(int count, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Artikel aktualisiert',
      one: 'Artikel aktualisiert',
    );
    return '$count $_temp0 auf \"$listName\"';
  }

  @override
  String shoppingAddError(String message) {
    return 'Fehler: $message';
  }

  @override
  String get editCookbook => 'Kochbuch bearbeiten';

  @override
  String get newCookbook => 'Neues Kochbuch';

  @override
  String get tapToAddCoverImage => 'Tippen, um ein Titelbild hinzuzufügen';

  @override
  String get cookbookDescriptionLabel => 'Beschreibung';

  @override
  String get cookbookDescriptionHint => 'Eine Sammlung von Rezepten...';

  @override
  String get cookbookNameRequired => 'Bitte gib einen Namen ein';

  @override
  String get addCover => 'Titelbild';

  @override
  String recipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rezepte',
      one: 'Rezept',
    );
    return '$count $_temp0';
  }

  @override
  String cookbookDeleteWithRecipes(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rezepte',
      one: 'Rezept',
    );
    return 'Dieses Kochbuch enthält $count $_temp0. Sie werden in den Papierkorb verschoben.\n\nMöchtest du \"$name\" wirklich löschen?';
  }

  @override
  String cookbookDeleteConfirmNamed(String name) {
    return 'Möchtest du \"$name\" wirklich löschen?';
  }

  @override
  String get shareCookbook => 'Kochbuch teilen';

  @override
  String get cookbookEmpty => 'Dieses Kochbuch hat keine Rezepte zum Teilen';

  @override
  String get recipes => 'Rezepte';

  @override
  String get sendSuggestion => 'Vorschlag senden';

  @override
  String get sendSuggestionSubtitle => 'Hilf uns, Recipe Spellbook zu verbessern';

  @override
  String get reportBug => 'Fehler melden';

  @override
  String get reportBugSubtitle => 'Funktioniert etwas nicht richtig?';

  @override
  String get joinDiscord => 'Unserem Discord beitreten';

  @override
  String get joinDiscordSubtitle => 'Hilfe erhalten, chatten und Rezepte teilen';

  @override
  String get actionSend => 'Senden';

  @override
  String get suggestionDescription => 'Wir freuen uns über deine Ideen! Dein Vorschlag wird direkt an unser Team gesendet.';

  @override
  String get suggestionTitleLabel => 'Titel des Vorschlags';

  @override
  String get suggestionTitleHint => 'z.B., Dunkelmodus für den Kochbildschirm';

  @override
  String get suggestionDetailsLabel => 'Details';

  @override
  String get suggestionDetailsHint => 'Beschreibe deine Idee im Detail...';

  @override
  String get contactOptionalLabel => 'Kontakt (optional)';

  @override
  String get contactOptionalHint => 'E-Mail oder Discord-Benutzername';

  @override
  String get suggestionSent => 'Danke! Dein Vorschlag wurde gesendet 💡';

  @override
  String get bugDescription => 'Einen Fehler gefunden? Lass es uns wissen und wir beheben ihn. Geräteinformationen werden automatisch mitgesendet.';

  @override
  String get bugTitleLabel => 'Fehlertitel';

  @override
  String get bugTitleHint => 'z.B., App stürzt beim PDF-Import ab';

  @override
  String get bugDetailsLabel => 'Was ist passiert?';

  @override
  String get bugDetailsHint => 'Beschreibe, was schiefgelaufen ist...';

  @override
  String get bugStepsLabel => 'Schritte zum Reproduzieren (optional)';

  @override
  String get bugStepsHint => '1. Rezept öffnen\n2. Teilen antippen\n3. App stürzt ab';

  @override
  String get bugReportSent => 'Danke! Dein Fehlerbericht wurde gesendet 🐛';

  @override
  String get feedbackFieldsRequired => 'Bitte fülle Titel und Details aus';

  @override
  String get feedbackSendError => 'Senden fehlgeschlagen. Überprüfe deine Internetverbindung.';

  @override
  String get mealTypeAppetizer => 'Vorspeise';

  @override
  String get allergenContains => 'Enthält';

  @override
  String get settingsIngredientLayout => 'Zutatenlayout';

  @override
  String get ingredientLayoutInline => 'Inline — 1 TL Butter';

  @override
  String get ingredientLayoutColumnar => 'Spalten — Mengen ausgerichtet';

  @override
  String get settingsIngredientLayoutDescription => 'Wähle aus, wie Mengenangaben und Namen der Zutaten in Rezepten, Einkaufslisten und im Druck angezeigt werden.';

  @override
  String get ingredientLayoutInlineDescription => 'Menge, Einheit und Name fließen natürlich zusammen';

  @override
  String get ingredientLayoutColumnarDescription => 'Mengenangaben sind in einer festen Spalte ausgerichtet für einfaches Erfassen';

  @override
  String get ingredientLayoutInfoText => 'Diese Einstellung gilt für die Rezeptansicht, den Einkaufslistengenerator und gedruckte Rezepte.';

  @override
  String get searchCookbooks => 'Kochbücher suchen...';

  @override
  String get aboutWebsite => 'Webseite';

  @override
  String get aboutPrivacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get aboutPrivacyPolicySub => 'Wie wir mit deinen Daten umgehen';

  @override
  String get aboutTermsOfService => 'Nutzungsbedingungen';

  @override
  String get aboutTermsOfServiceSub => 'Bedingungen und Konditionen';

  @override
  String get aboutCommunity => 'Community';

  @override
  String get aboutCommunitySub => 'Tritt unserem Discord-Server bei';

  @override
  String get aboutReportBug => 'Fehler melden';

  @override
  String get aboutReportBugSub => 'Hilf uns, die App zu verbessern';

  @override
  String get aboutRateApp => 'App bewerten';

  @override
  String get aboutRateAppSub => 'Hinterlasse eine Bewertung im Store';

  @override
  String get aboutLicenses => 'Open-Source-Lizenzen';

  @override
  String get aboutLicensesSub => 'Verwendete Drittanbieter-Software';

  @override
  String get sortOrder => 'Sortieren';

  @override
  String get ingredientAddHeader => 'Überschrift';

  @override
  String get saveAsRecipe => 'Als Rezept speichern';

  @override
  String get exportFullBackup => 'Vollständiges Backup';

  @override
  String get exportCookbooksRecipes => 'Kochbücher und Rezepte';

  @override
  String get exportShoppingLists => 'Einkaufslisten';

  @override
  String get exportMealPlans => 'Mahlzeitenpläne';

  @override
  String get exportTags => 'Tags';

  @override
  String get exportCategories => 'Benutzerdefinierte Kategorien';

  @override
  String get exportCourses => 'Benutzerdefinierte Gänge';

  @override
  String get createRecipeManually => 'Oder Rezept manuell erstellen';

  @override
  String get transferYourRecipes => 'Übertrage deine Rezepte';

  @override
  String get transferUpgradeBanner => 'Automatische Synchronisierung gewünscht? Upgrade auf Premium für Cloud-Sync auf allen deinen Geräten.';

  @override
  String get transferCodeLength => 'Code muss 6 Zeichen lang sein';

  @override
  String get transferItemRecipes => 'Alle Rezepte';

  @override
  String get transferItemCookbooks => 'Kochbücher & Kategorien';

  @override
  String get transferItemMealPlans => 'Essenspläne';

  @override
  String get transferItemShoppingLists => 'Einkaufslisten';

  @override
  String get transferItemSettings => 'App-Einstellungen';

  @override
  String get transferItemAccount => 'Kontoanmeldung (falls Absender angemeldet ist)';

  @override
  String get codeCopied => 'Code kopiert!';

  @override
  String get transferTitle => 'Daten übertragen';

  @override
  String get transferReceiveSubtitle => 'Gib einen Code ein oder scanne den QR vom sendenden Gerät';

  @override
  String get transferPreparing => 'Deine Daten werden vorbereitet...';

  @override
  String get transferFailed => 'Übertragung fehlgeschlagen';

  @override
  String get transferScanDesc => 'Scanne diesen QR auf deinem anderen Gerät oder gib den Code unten ein.';

  @override
  String get transferReady => 'Bereit zur Übertragung';

  @override
  String get transferCodeExpires => 'Dieser Code läuft in 15 Minuten ab';

  @override
  String get transferComplete => 'Übertragung abgeschlossen!';

  @override
  String get transferAccountSynced => 'Konto vom Absender angemeldet';

  @override
  String get transferScanQr => 'QR-Code scannen';

  @override
  String get transferScanQrDesc => 'Richte deine Kamera auf den QR auf dem anderen Gerät';

  @override
  String get transferEnterCode => 'Übertragungscode eingeben';

  @override
  String get transferWhatMoves => 'Was wird übertragen:';

  @override
  String get transferMergeNote => 'Vorhandene Daten auf diesem Gerät werden zusammengeführt. Duplikate werden übersprungen.';

  @override
  String get transferPointCamera => 'Richte die Kamera auf den QR-Code des sendenden Geräts';

  @override
  String get labelPrepMin => 'Vorb. (Min)';

  @override
  String get labelCookMin => 'Kochen (Min)';

  @override
  String get labelTotalCal => 'Gesamt kcal';

  @override
  String get labelCalPerServing => 'kcal/Portion';

  @override
  String get tooltipViewSize => 'Anzeigegröße';

  @override
  String get pantryClearTitle => 'Vorratskammer leeren?';

  @override
  String get pantryAddHint => 'Artikel zur Vorratskammer hinzufügen...';

  @override
  String get pantryAddStaples => 'Alle Grundzutaten hinzufügen';

  @override
  String get pantrySearchHint => 'Vorratskammer durchsuchen...';

  @override
  String get settingsRecipesShopping => 'Rezepte & Einkauf';

  @override
  String get settingsAdvanced => 'Erweiterte Einstellungen';

  @override
  String get settingsAdvancedSubtitle => 'Tags, Gänge, Kategorien & mehr';

  @override
  String get settingsRestoreDefaults => 'Restore Default Recipes';

  @override
  String get settingsRestoreDefaultsSubtitle => 'Re-add the 10 starter recipes';

  @override
  String get settingsRestoreDefaultsConfirm => 'Add 10 starter recipes to your cookbook? Existing recipes won\'t be affected.';

  @override
  String get settingsDeleteData => 'Daten löschen';

  @override
  String get settingsDeleteDataSubtitle => 'App- oder Cloud-Daten löschen';

  @override
  String get settingsUpgradeSubtitle => 'Cloud-Sync, Fotos & mehr';

  @override
  String get settingsTextSizeSubtitle => 'Textgröße in der gesamten App anpassen';

  @override
  String get settingsGoogleOrApple => 'Google oder Apple';

  @override
  String get alwaysVisible => 'Immer sichtbar';

  @override
  String get chartNumbers => 'Zahlen';

  @override
  String get chartDonut => 'Donut';

  @override
  String get chartBars => 'Balken';

  @override
  String get unitKcal => 'kcal';

  @override
  String get nutritionCustomScale => 'Benutzerdefinierte Skalierung';

  @override
  String get nutritionScaleLabel => 'Skalierungsfaktor';

  @override
  String get nutritionScaleHint => 'z.B. 0,5, 1,5, 3,0';

  @override
  String get nutritionSet => 'Festlegen';

  @override
  String get nutritionApplyRecalculate => 'Anwenden & Neuberechnen';

  @override
  String get calAbbrev => 'kcal';

  @override
  String get nutritionServingSizeHint => 'z.B. 1 Tasse, 100g';

  @override
  String get shoppingExportList => 'Liste exportieren';

  @override
  String get shoppingExportListSubtitle => 'Als Textdatei teilen oder sichern';

  @override
  String get shoppingImportList => 'Liste importieren';

  @override
  String get shoppingImportListSubtitle => 'Artikel aus Datei, Foto oder Text hinzufügen';

  @override
  String get shoppingScanBarcodeSubtitle => 'Produkt nachschlagen und hinzufügen';

  @override
  String get exportBackupFile => 'Backup-Datei';

  @override
  String get exportBackupFileSubtitle => 'Zum Übertragen auf ein anderes Gerät oder eine andere App';

  @override
  String get exportFormattedList => 'Formatierte Liste';

  @override
  String get exportFormattedListSubtitle => 'Mit Kontrollkästchen — ideal für Notiz-Apps';

  @override
  String get exportPlainText => 'Klartext';

  @override
  String get exportPlainTextSubtitle => 'Einfache Liste — überall einfügen';

  @override
  String get importFromBackupFile => 'Aus Backup-Datei';

  @override
  String get importFromBackupSubtitle => 'Ein Recipe Spellbook-Backup importieren';

  @override
  String get importFromTextShoppingSubtitle => 'Einfügen oder eine Artikelliste eintippen';

  @override
  String get importFromPhotoOcrSubtitle => 'OCR-Scan einer handgeschriebenen oder gedruckten Liste';

  @override
  String get importFromPhotoGallerySubtitle => 'Foto machen oder aus Galerie wählen';

  @override
  String get shoppingSendToStore => 'An den Laden senden';

  @override
  String get shoppingSendToCart => 'In den Warenkorb senden';

  @override
  String get shoppingCopyToClipboard => 'Liste in Zwischenablage kopieren';

  @override
  String get shoppingGoToCart => 'Zum Warenkorb';

  @override
  String get shoppingAddItems => 'Artikel hinzufügen';

  @override
  String get shoppingAddItemHintLong => 'z.B. 2 Tassen Mehl, Hähnchenbrust...';

  @override
  String get importReviewItems => 'Artikel überprüfen';

  @override
  String get importNoItemsDetected => 'Keine Artikel erkannt';

  @override
  String get mealPlanDate => 'Datum';

  @override
  String get mealPlanThisWeekend => 'Dieses Wochenende';

  @override
  String get menuKitchenBuddy => 'RPG-Profil';

  @override
  String get menuTools => 'Werkzeuge';

  @override
  String get menuSupport => 'Support';

  @override
  String get menuHowCanWeHelp => 'Wie können wir helfen?';

  @override
  String get menuGetInTouch => 'Kontaktiere uns oder durchstöbere unsere Anleitungen.';

  @override
  String get menuVisitWebsite => 'Unsere Webseite besuchen';

  @override
  String get feedbackTitleLabel => 'Titel';

  @override
  String get feedbackDetailsLabel => 'Details';

  @override
  String get feedbackDescriptionLabel => 'Beschreibung';

  @override
  String get menuSigningIn => 'Anmeldung läuft…';

  @override
  String get menuSignInSync => 'Anmelden zum Synchronisieren & Sichern';

  @override
  String get tagsSave => 'Tags speichern';

  @override
  String get recipeFieldCategories => 'Kategorien';

  @override
  String get selectCategories => 'Kategorien auswählen';

  @override
  String get searchOrCreateNew => 'Suchen oder neu erstellen...';

  @override
  String get noMatchesFound => 'Keine Treffer gefunden';

  @override
  String get taxonomyAddCategoryNew => 'Als neue Kategorie hinzufügen';

  @override
  String get ingredientSubstitutionsTitle => 'Zutatenersatz';

  @override
  String get ingredientSubstitutionsSearch => 'Zutat suchen...';

  @override
  String get ingredientSubstitutionsSearchAll => 'Alle Ersatzstoffe durchsuchen';

  @override
  String get ingredientName => 'Zutatenname';

  @override
  String get ingredientNameHint => 'z.B. Kurkuma, Tahini, Miso';

  @override
  String get ingredientBulkHint => 'Eine Zutat pro Zeile eingeben:\n\n2 Tassen Mehl\n1 TL Salz\n3 Eier';

  @override
  String get viewPlans => 'Pläne ansehen';

  @override
  String get renewsLabel => 'Verlängerung';

  @override
  String get upgradeToProUnlock => 'Auf Pro upgraden zum Freischalten';

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
  String get settingsNoMatchingSettings => 'Keine passenden Einstellungen';

  @override
  String get settingsSearchHint => 'Einstellungen suchen...';

  @override
  String get textSizeSmall => 'Klein';

  @override
  String get textSizeDefault => 'Standard';

  @override
  String get textSizeMedium => 'Mittel';

  @override
  String get textSizeLarge => 'Groß';

  @override
  String get textSizeExtraLarge => 'Sehr groß';

  @override
  String get resetDataClearedDesc => 'Alle Daten wurden erfolgreich gelöscht.\n\nMöchtest du die 10 Standard-Starterrezepte importieren?';

  @override
  String get yesImport => 'Ja, importieren';

  @override
  String get importingDefaultRecipes => 'Standardrezepte werden importiert...';

  @override
  String get checking => 'Wird überprüft...';

  @override
  String get connectedTapToManage => 'Verbunden • Zum Verwalten tippen';

  @override
  String get notConnected => 'Nicht verbunden';

  @override
  String get tapToSignIn => 'Zum Anmelden tippen';

  @override
  String get noneSelected => 'Keine Auswahl';

  @override
  String get partialBackup => 'Teilweises Backup';

  @override
  String get settingsShopping => 'Einkauf & Planung';

  @override
  String get settingsManage => 'Verwalten';

  @override
  String get manageTags => 'Tags verwalten';

  @override
  String tagsApplied(int count) {
    return '$count Tags angewendet';
  }

  @override
  String tagsEditTitle(String name) {
    return '\"$name\" bearbeiten';
  }

  @override
  String get tagsEditComingSoon => 'Tag-Bearbeitung bald verfügbar!';

  @override
  String tagsRecipeCount(int count) {
    return '$count Rezepte';
  }

  @override
  String get communityMyPublications => 'Meine Veröffentlichungen';

  @override
  String get communitySearchCookbooks => 'Kochbücher suchen...';

  @override
  String get communitySortRecent => 'Neueste';

  @override
  String get communitySortPopular => 'Beliebt';

  @override
  String get communitySortMostDownloaded => 'Am häufigsten heruntergeladen';

  @override
  String communityNoResultsFor(String query) {
    return 'Keine Ergebnisse für \"$query\"';
  }

  @override
  String get communityNoCookbooksYet => 'Noch keine Kochbücher';

  @override
  String get communityClearSearch => 'Suche löschen';

  @override
  String get communityPublish => 'Veröffentlichen';

  @override
  String communityByPublisher(String name) {
    return 'von $name';
  }

  @override
  String communityRecipeCount(int count) {
    return '$count Rezepte';
  }

  @override
  String get communityPublishCookbook => 'Kochbuch veröffentlichen';

  @override
  String get communitySignInToPublish => 'Zum Veröffentlichen anmelden';

  @override
  String get communitySignInToPublishMessage => 'Du benötigst ein Konto, um Kochbücher mit der Community zu teilen.';

  @override
  String get communityGoToSettings => 'Zu den Einstellungen';

  @override
  String get communityNoCookbooksToPublish => 'Keine Kochbücher zum Veröffentlichen';

  @override
  String get communityPublishInfo => 'Kochbücher benötigen mindestens 10 Rezepte zum Veröffentlichen. Deine Rezepte werden als Momentaufnahme geteilt — Änderungen werden nicht synchronisiert.';

  @override
  String get communitySelectCookbook => 'Wähle ein Kochbuch zum Veröffentlichen';

  @override
  String communityNeedMinRecipes(int count) {
    return 'Mindestens 10 Rezepte erforderlich (hat $count)';
  }

  @override
  String get communityPublishConfirmTitle => 'In der Community veröffentlichen?';

  @override
  String communityPublishConfirmMessage(String name, int count) {
    return '\"$name\" ($count Rezepte) wird öffentlich geteilt. Jeder kann es durchsuchen und herunterladen.\n\nDu kannst es jederzeit zurückziehen.';
  }

  @override
  String communityPublishSuccess(String name) {
    return '\"$name\" in der Community veröffentlicht!';
  }

  @override
  String get communityPublishFailed => 'Veröffentlichung fehlgeschlagen';

  @override
  String communityRecipeCountNeedMore(int count) {
    return '$count Rezepte (benötigt 10+)';
  }

  @override
  String get communityNoPublicationsYet => 'Noch keine Veröffentlichungen';

  @override
  String get communityNoPublicationsMessage => 'Veröffentliche ein Kochbuch, um es mit der Community zu teilen.';

  @override
  String get communityUnpublish => 'Zurückziehen';

  @override
  String get communityUnpublishConfirmTitle => 'Zurückziehen?';

  @override
  String communityUnpublishConfirmMessage(String title) {
    return '\"$title\" aus der Community entfernen? Personen, die es bereits heruntergeladen haben, behalten ihre Kopie.';
  }

  @override
  String communityUnpublishSuccess(String title) {
    return '\"$title\" zurückgezogen';
  }

  @override
  String get communityUnpublishFailed => 'Zurückziehen fehlgeschlagen';

  @override
  String get communityRemovedByModeration => 'Durch Moderation entfernt';

  @override
  String communityPublicationStats(int recipeCount, int downloadCount, String timeAgo) {
    return '$recipeCount Rezepte · $downloadCount Downloads · $timeAgo';
  }

  @override
  String get communityPublicationNotFound => 'Veröffentlichung nicht gefunden';

  @override
  String get communityReport => 'Melden';

  @override
  String get communityReportTitle => 'Dieses Kochbuch melden';

  @override
  String get communityReportSpam => 'Spam oder geringe Qualität';

  @override
  String get communityReportInappropriate => 'Unangemessener Inhalt';

  @override
  String get communityReportStolen => 'Gestohlene / kopierte Rezepte';

  @override
  String get communityReportOther => 'Sonstiges';

  @override
  String get communityReportSuccess => 'Meldung eingereicht. Vielen Dank!';

  @override
  String get communitySignInToReport => 'Zum Melden anmelden';

  @override
  String get communityDownloadFailed => 'Download fehlgeschlagen';

  @override
  String communityDownloadSuccess(String title, int count) {
    return '\"$title\" heruntergeladen — $count Rezepte hinzugefügt!';
  }

  @override
  String communityDownloadFailedError(String error) {
    return 'Download fehlgeschlagen: $error';
  }

  @override
  String communityDownloadCount(int count) {
    return '$count Downloads';
  }

  @override
  String get communityDownloading => 'Wird heruntergeladen...';

  @override
  String get communityDownloadToMyCookbooks => 'In meine Kochbücher herunterladen';

  @override
  String communityPrepTime(int minutes) {
    return '${minutes}m Vorb.';
  }

  @override
  String communityCookTime(int minutes) {
    return '${minutes}m Kochen';
  }

  @override
  String communityServingsCount(int count) {
    return '$count Portionen';
  }

  @override
  String communityIngredientCount(int count) {
    return '$count Zutaten';
  }

  @override
  String get deleteRecipesTrashMessage => 'Rezepte werden in den Papierkorb verschoben. Du kannst sie später wiederherstellen.';

  @override
  String get hintTitleExample => 'z.B. Omas Apfelkuchen';

  @override
  String get hintDescription => 'Eine kurze Beschreibung des Rezepts';

  @override
  String get hintServingsExample => 'z.B. 4';

  @override
  String get prepMin => 'Vorb. (Min)';

  @override
  String get cookMin => 'Kochen (Min)';

  @override
  String get hintNotes => 'Tipps, Variationen, Lagerungshinweise...';

  @override
  String get pinchToZoomCropped => 'Zum Zoomen zusammenziehen · Zugeschnittener Bereich wird gespeichert';

  @override
  String get pinchToZoomOrUseAsIs => 'Zum Zoomen und Zuschneiden zusammenziehen · Oder so verwenden';

  @override
  String get savingLabel => 'Wird gespeichert...';

  @override
  String get emptyHeader => '(leere Überschrift)';

  @override
  String get emptyIngredient => '(leere Zutat)';

  @override
  String get recipeUpdated => 'Rezept aktualisiert!';

  @override
  String get nutritionLessInfo => 'Weniger Infos';

  @override
  String get nutritionMoreInfo => 'Mehr Infos';

  @override
  String scaleOriginal(String servings) {
    return 'Original: $servings';
  }

  @override
  String get scaleAdjustQuantities => 'Zutatenmengen anpassen';

  @override
  String get scaleOriginalLabel => '1x (Original)';

  @override
  String get stepWillBeRemoved => 'Dieser Schritt wird endgültig entfernt.';

  @override
  String stepsWillBeRemoved(int count) {
    return 'Diese $count Schritte werden endgültig entfernt.';
  }

  @override
  String stepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Schritte',
      one: '1 Schritt',
    );
    return '$_temp0';
  }

  @override
  String get instructionsNoSteps => 'Noch keine Anleitung';

  @override
  String get instructionsAddStepsGuide => 'Füge Schritte hinzu, um durch das Rezept zu führen';

  @override
  String get pinchToZoomPreview => 'Zum Zoomen zusammenziehen · So wird dein Foto aussehen';

  @override
  String ingredientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zutaten',
      one: '1 Zutat',
    );
    return '$_temp0';
  }

  @override
  String get ingredientPerLineHint => 'Eine Zutat pro Zeile eingeben:\n\n2 Tassen Mehl\n1 TL Salz\n3 Eier';

  @override
  String get ingredientTip => 'Tipp: Gib eine Zutat pro Zeile ein. Drücke nach jeder Zutat Enter.';

  @override
  String get cookbookEditSubtitle => 'Umbenennen, Titelbild';

  @override
  String get shareCookbookSubtitle => 'Link, Familie oder Community';

  @override
  String shareNamedCookbook(String name) {
    return '\"$name\" teilen';
  }

  @override
  String shareNamedList(String name) {
    return '\"$name\" teilen';
  }

  @override
  String get shareAsTextDescription => 'Listeneinträge als Text senden';

  @override
  String get oneTimeLink => 'Einmaliger Link';

  @override
  String get oneTimeLinkDescription => 'Kostenlos • 24h Ablauf • Jeder kann herunterladen';

  @override
  String get familyShare => 'Familienfreigabe';

  @override
  String get familyShareDescription => 'Echtzeit-Synchronisierung mit Familienmitgliedern';

  @override
  String get postToCommunity => 'In der Community veröffentlichen';

  @override
  String get postToCommunityDescription => 'Für alle zum Entdecken & Herunterladen veröffentlichen';

  @override
  String get signInToShare => 'Zum Erstellen von Teilen-Links anmelden';

  @override
  String get generatingLink => 'Link wird erstellt...';

  @override
  String get failedToCreateLink => 'Link konnte nicht erstellt werden';

  @override
  String get linkCreated => 'Link erstellt!';

  @override
  String get expiresIn24Hours => 'Läuft in 24 Stunden ab';

  @override
  String get linkCopied => 'Link kopiert!';

  @override
  String unlockFeature(String feature) {
    return '$feature freischalten';
  }

  @override
  String get notNow => 'Nicht jetzt';

  @override
  String get upgradeButton => 'Upgraden';

  @override
  String publishMinRecipes(int count) {
    return 'Mindestens 10 Rezepte erforderlich (hat $count)';
  }

  @override
  String get publishConfirmTitle => 'In der Community veröffentlichen?';

  @override
  String publishConfirmMessage(String name, int count) {
    return '\"$name\" ($count Rezepte) wird öffentlich sichtbar. Jeder kann es durchsuchen und herunterladen.\n\nDu kannst es jederzeit unter Community → Meine Veröffentlichungen entfernen.';
  }

  @override
  String get publishButton => 'Veröffentlichen';

  @override
  String get selectCourse => 'Gang auswählen';

  @override
  String get selectCategory => 'Kategorie auswählen';

  @override
  String get taxonomyNone => 'Keine';

  @override
  String createTaxonomy(String name) {
    return '\"$name\" erstellen';
  }

  @override
  String get addAsNewCourse => 'Als neuen Gang hinzufügen';

  @override
  String get addAsNewCategory => 'Als neue Kategorie hinzufügen';

  @override
  String doneWithCount(int count) {
    return 'Fertig ($count)';
  }

  @override
  String get quickAccessEmptyAll => 'Noch keine Schnellzugriff-Rezepte';

  @override
  String get quickAccessEmptyMealPlan => 'Keine Mahlzeiten geplant';

  @override
  String get quickAccessEmptyPinned => 'Keine angehefteten Rezepte';

  @override
  String get quickAccessEmptyRecent => 'Keine kürzlichen Rezepte';

  @override
  String get importingRecipe => 'Rezept wird importiert…';

  @override
  String errorWithMessage(String message) {
    return 'Fehler: $message';
  }

  @override
  String get minutesPrepSuffix => 'm Vorb.';

  @override
  String get minutesCookSuffix => 'm Kochen';

  @override
  String get couldNotOpenBrowser => 'Browser konnte nicht geöffnet werden';

  @override
  String couldNotOpenUrl(String url) {
    return '$url konnte nicht geöffnet werden';
  }

  @override
  String get discord => 'Discord';

  @override
  String get discordLinkAccount => 'Discord-Konto verknüpfen';

  @override
  String get discordLinkSubtitle => 'Verbinde dein Discord für Community-Funktionen';

  @override
  String get discordSignInFirst => 'Zuerst anmelden, um Discord zu verknüpfen';

  @override
  String get discordUnlink => 'Discord trennen';

  @override
  String get discordUnlinkFailed => 'Discord-Trennung fehlgeschlagen';

  @override
  String get discordUnlinkSubtitle => 'Deine Discord-Verbindung entfernen';

  @override
  String get discordUnlinked => 'Discord getrennt';

  @override
  String get familyCodeCopied => 'Einladungscode kopiert!';

  @override
  String get familyCopyLink => 'Link kopieren';

  @override
  String get familyCreate => 'Familie erstellen';

  @override
  String get familyCreateFailed => 'Familie konnte nicht erstellt werden';

  @override
  String get familyCreateTitle => 'Familie erstellen';

  @override
  String get familyCreated => 'Familie erstellt!';

  @override
  String get familyDelete => 'Familie löschen';

  @override
  String get familyDeleteConfirm => 'Bist du sicher, dass du diese Familie löschen möchtest? Alle Mitglieder werden entfernt.';

  @override
  String get familyDeleted => 'Familie gelöscht';

  @override
  String get familyEnterInviteCode => 'Einladungscode eingeben';

  @override
  String get familyInvite => 'Mitglieder einladen';

  @override
  String get familyJoinAction => 'Beitreten';

  @override
  String get familyJoinFailed => 'Familienbeitritt fehlgeschlagen';

  @override
  String get familyJoinTitle => 'Familie beitreten';

  @override
  String get familyJoinWithCode => 'Mit Code beitreten';

  @override
  String familyJoined(String familyName) {
    return '$familyName beigetreten!';
  }

  @override
  String get familyLeave => 'Familie verlassen';

  @override
  String get familyLeaveAction => 'Verlassen';

  @override
  String get familyLeaveConfirm => 'Bist du sicher, dass du diese Familie verlassen möchtest?';

  @override
  String get familyLeft => 'Familie verlassen';

  @override
  String get familyLinkCopied => 'Einladungslink kopiert!';

  @override
  String get familyManage => 'Deine Familie verwalten';

  @override
  String familyMemberRemoved(String displayName) {
    return '$displayName entfernt';
  }

  @override
  String get familyMembers => 'Mitglieder';

  @override
  String familyMembersCount(int current, int max) {
    return '$current von $max Mitgliedern';
  }

  @override
  String get familyNameHint => 'Familienname';

  @override
  String get familyNewCodeGenerated => 'Neuer Einladungscode generiert';

  @override
  String get familyOwner => 'BESITZER';

  @override
  String get familyRegenerateCode => 'Code neu generieren';

  @override
  String get familyRemoveMember => 'Mitglied entfernen';

  @override
  String familyRemoveMemberConfirm(String displayName) {
    return '$displayName aus der Familie entfernen?';
  }

  @override
  String get familyRename => 'Familie umbenennen';

  @override
  String familyShareMessage(String inviteCode, String shareLink) {
    return 'Tritt meiner Familie auf Recipe Spellbook bei! Code: $inviteCode oder nutze diesen Link: $shareLink';
  }

  @override
  String get familyShareSubject => 'Tritt meiner Recipe Spellbook-Familie bei';

  @override
  String get familyShareUpgradeMessage => 'Upgrade, um Kochbücher in Echtzeit mit Familienmitgliedern zu teilen.';

  @override
  String get familySharing => 'Familienfreigabe';

  @override
  String get familySharingDescription => 'Teile Kochbücher, Einkaufslisten und Essenspläne mit deiner Familie.';

  @override
  String get familySharingSubtitle => 'Kochbücher, Listen & Essenspläne teilen';

  @override
  String ingredientSubstitutesFor(String ingredientName) {
    return 'Ersatz für $ingredientName';
  }

  @override
  String get ingredientSubstitutionsNoResults => 'Keine Ersatzstoffe gefunden';

  @override
  String ingredientSubstitutionsNotFound(String ingredientName) {
    return 'Keine Ersatzstoffe für $ingredientName gefunden';
  }

  @override
  String get ingredientSubstitutionsTryDifferent => 'Versuche eine andere Zutat';

  @override
  String get integrationsChecking => 'Wird überprüft...';

  @override
  String get integrationsConnectedManage => 'Verbunden – Zum Verwalten tippen';

  @override
  String get integrationsLinked => 'Verknüpft';

  @override
  String get integrationsLinkedManage => 'Verknüpft – Zum Verwalten tippen';

  @override
  String get integrationsNotConnected => 'Nicht verbunden';

  @override
  String get integrationsTapToLink => 'Zum Verknüpfen tippen';

  @override
  String get integrationsTapToSignIn => 'Zum Anmelden tippen';

  @override
  String get nutritionCalculateFromEdit => 'Aus dem Bearbeitungsbildschirm berechnen';

  @override
  String get nutritionCaloriesAlwaysShow => 'Kalorien immer anzeigen';

  @override
  String get nutritionChartStyle => 'Diagrammstil';

  @override
  String get nutritionResetDefaults => 'Auf Standard zurücksetzen';

  @override
  String get nutritionSettingsLink => 'Nährwerteinstellungen';

  @override
  String get nutritionTapToCalculate => 'Tippen, um Nährwerte zu berechnen';

  @override
  String get nutritionVisibleNutrients => 'Sichtbare Nährstoffe';

  @override
  String pantryAddedStaples(int count) {
    return '$count Grundzutaten zur Vorratskammer hinzugefügt';
  }

  @override
  String get pantryClearAll => 'Alle löschen';

  @override
  String get pantryClearMessage => 'Alle Artikel aus deiner Vorratskammer entfernen?';

  @override
  String get pantryCommonStaples => 'Häufige Grundzutaten';

  @override
  String get pantryEmpty => 'Deine Vorratskammer ist leer';

  @override
  String get pantryEmptySubtitle => 'Füge Artikel hinzu, die du immer vorrätig hast';

  @override
  String get pantryInfoMessage => 'Artikel in deiner Vorratskammer werden von Einkaufslisten ausgeschlossen, wenn du Rezeptzutaten hinzufügst.';

  @override
  String pantryItemCount(int count) {
    return '$count Artikel';
  }

  @override
  String get mealPlanAddTitle => 'Zum Speiseplan hinzufügen';

  @override
  String get mealPlanMealLabel => 'Mahlzeit';

  @override
  String get mealPlanAdding => 'Wird hinzugefügt...';

  @override
  String mealPlanDateFormat(String weekday, String month, int day) {
    return '$weekday, $day. $month';
  }

  @override
  String get splashRecipe => 'Rezept';

  @override
  String get splashSpellbook => 'Zauberbuch';

  @override
  String get splashTagline => 'Dein kulinarisches Abenteuer wartet';

  @override
  String get servingSizeHint => 'z.B. 1 Tasse, 100g';

  @override
  String get mainNutrients => 'Hauptnährstoffe';

  @override
  String get additionalNutrients => 'Weitere Nährstoffe';

  @override
  String get onboardingWelcomeTo => 'Willkommen bei';

  @override
  String get onboardingAppName => 'Recipe Spellbook!';

  @override
  String get onboardingDescription => '10 handverlesene Rezepte aus aller Welt für deinen Start.';

  @override
  String get onboardingDeleteLater => 'Du kannst sie jederzeit wieder löschen.';

  @override
  String get onboardingAdding => 'Wird hinzugefügt...';

  @override
  String get onboardingAddStarter => 'Starterrezepte hinzufügen';

  @override
  String get onboardingBlankCookbook => 'Mit leerem Kochbuch starten';

  @override
  String get onboardingBlankConfirmTitle => 'Start with nothing?';

  @override
  String get onboardingBlankConfirmBody => 'You can always add the starter recipes later from Settings.';

  @override
  String get onboardingBlankConfirmYes => 'Yes, start empty';

  @override
  String get onboardingSpellbookAwaits => 'Dein Zauberbuch wartet';

  @override
  String get onboardingYourSpellbookAwaits => 'Dein Zauberbuch wartet...';

  @override
  String get onboardingSummoning => 'Beschwöre...';

  @override
  String get onboardingBlankSpellbook => 'Mit einem leeren Zauberbuch starten';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get settingsBrowseCommunity => 'Community durchstöbern';

  @override
  String get settingsBrowseCommunitySubtitle => 'Öffentliche Kochbücher entdecken';

  @override
  String get settingsCommunity => 'Community';

  @override
  String get settingsFamily => 'Familie';

  @override
  String get settingsIntegrations => 'Integrationen';

  @override
  String get settingsMyPublications => 'Meine Veröffentlichungen';

  @override
  String get settingsMyPublicationsSubtitle => 'Veröffentlichte Kochbücher verwalten';

  @override
  String get settingsShoppingPlanning => 'Einkauf & Planung';

  @override
  String shoppingAddCountItems(int count) {
    return '$count Artikel hinzufügen';
  }

  @override
  String get shoppingAddIngredient => 'Zutat hinzufügen';

  @override
  String shoppingAddedItemName(String name) {
    return '\"$name\" hinzugefügt';
  }

  @override
  String shoppingAddedNotFound(int added, int failed) {
    return '$added hinzugefügt, $failed nicht gefunden';
  }

  @override
  String shoppingAddingTo(String provider) {
    return 'Wird zu $provider hinzugefügt…';
  }

  @override
  String get shoppingCamera => 'Kamera';

  @override
  String shoppingCheckedItemsCount(int count) {
    return 'Abgehakte Artikel ($count)';
  }

  @override
  String shoppingCouldNotAccessSource(String source) {
    return 'Konnte nicht auf $source zugreifen';
  }

  @override
  String shoppingCountAdded(int count) {
    return '$count hinzugefügt';
  }

  @override
  String shoppingCreatingListOn(String provider) {
    return 'Liste wird auf $provider erstellt…';
  }

  @override
  String shoppingCurrentOfTotal(int current, int total) {
    return '$current von $total Artikeln';
  }

  @override
  String shoppingDeleteListConfirm(String name) {
    return 'Bist du sicher, dass du \"$name\" löschen möchtest?';
  }

  @override
  String shoppingErrorReadingImage(String error) {
    return 'Fehler beim Lesen des Bildes: $error';
  }

  @override
  String shoppingExportFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String shoppingExportTitle(String name) {
    return '\"$name\" exportieren';
  }

  @override
  String get shoppingFamilyShare => 'Familienfreigabe';

  @override
  String get shoppingFamilyShareSubtitle => 'Liste mit Familie oder einmaligem Link teilen';

  @override
  String get shoppingFromPhoto => 'Vom Foto';

  @override
  String get shoppingFromText => 'Aus Text';

  @override
  String get shoppingGallery => 'Galerie';

  @override
  String get shoppingImportItems => 'Artikel importieren';

  @override
  String get shoppingImportShoppingList => 'Einkaufsliste importieren';

  @override
  String get shoppingImportTextHint => '2 Tassen Mehl\nHähnchenbrust\n500g Hackfleisch\nMilch\n...';

  @override
  String get shoppingImportedList => 'Importierte Liste';

  @override
  String get shoppingIngredientHint => 'z.B. Hähnchenbrust, Olivenöl';

  @override
  String get shoppingIngredientName => 'Zutatenname';

  @override
  String shoppingIngredientsAvailable(int count) {
    return '$count Zutaten verfügbar';
  }

  @override
  String shoppingItemsAddedCount(int count) {
    return '$count Artikel hinzugefügt';
  }

  @override
  String get shoppingItemsAddedSuccess => 'Artikel hinzugefügt!';

  @override
  String shoppingItemsCopiedToClipboard(int count) {
    return '$count Artikel in die Zwischenablage kopiert';
  }

  @override
  String shoppingItemsInCart(int count, String provider) {
    return '$count Artikel in deinem $provider-Warenkorb';
  }

  @override
  String shoppingItemsOnInstacartList(int count) {
    return '$count Artikel auf deiner Instacart-Liste';
  }

  @override
  String get shoppingJustAdded => 'Gerade hinzugefügt';

  @override
  String shoppingListCopiedOpening(String name) {
    return 'Liste kopiert! $name wird geöffnet...';
  }

  @override
  String get shoppingListReady => 'Einkaufsliste fertig!';

  @override
  String shoppingNotFoundItems(String items) {
    return 'Nicht gefunden: $items';
  }

  @override
  String get shoppingOneItemPerLine => 'Ein Artikel pro Zeile';

  @override
  String get shoppingPartiallyAdded => 'Teilweise hinzugefügt';

  @override
  String get shoppingProviderConnected => 'Verbunden';

  @override
  String get shoppingRemoveFromList => 'Von der Liste entfernen';

  @override
  String get shoppingStartTyping => 'Tippen, um Vorschläge zu sehen';

  @override
  String get shoppingTapToAddToCart => 'Tippen, um Artikel direkt in den Warenkorb zu legen';

  @override
  String get shoppingTapToCreateShoppableList => 'Tippen, um eine Einkaufsliste zu erstellen';

  @override
  String get swipeToSwitch => 'Wischen, um den Bereich zu wechseln';

  @override
  String get syncFailed => 'Synchronisierung fehlgeschlagen';

  @override
  String syncSuccess(int pushed, int pulled) {
    return 'Synchronisiert: $pushed gesendet, $pulled empfangen';
  }

  @override
  String get textSizePreview => 'Vorschau';

  @override
  String get transferDeviceDesktop => 'Desktop';

  @override
  String get transferDeviceMobileApp => 'mobile App';

  @override
  String get transferDeviceThisDevice => 'dieses Gerät';

  @override
  String transferExplanation(String currentDevice, String targetDevice) {
    return 'Verschiebe alle deine Rezepte, Kochbücher und Essenspläne von $currentDevice auf dein $targetDevice. Dies ist eine einmalige Kopie, keine Synchronisierung.';
  }

  @override
  String transferImportedSuccess(int count) {
    return '$count Elemente erfolgreich importiert.';
  }

  @override
  String get transferOr => 'ODER';

  @override
  String transferReceiveOn(String device) {
    return 'Empfangen auf $device';
  }

  @override
  String transferSendFrom(String device) {
    return 'Senden von $device';
  }

  @override
  String transferSendSubtitle(String device) {
    return 'Generiere einen Code, den dein $device empfangen kann';
  }

  @override
  String get importGuidesTitle => 'Import-Anleitungen';

  @override
  String get importGuidesOpenInBrowser => 'Anleitungen im Browser öffnen';

  @override
  String get importGuideHeroTitle => 'Bringe deine Rezepte von überall';

  @override
  String get importGuideHeroSubtitle => 'Tippe auf eine Anleitung für Schritt-für-Schritt-Anweisungen mit Screenshots.';

  @override
  String get importGuideQuickTipLabel => 'Schnelltipp';

  @override
  String get importGuideQuickTipText => 'Der schnellste Weg? Kopiere einen Rezeptlink und teile ihn mit Recipe Spellbook — funktioniert aus fast jeder App.';

  @override
  String get importGuideWebButton => 'Web';

  @override
  String get importGuideFollowInBrowser => 'Im Browser folgen';

  @override
  String get importGuideTagPopular => 'Beliebt';

  @override
  String get importGuideTagEasiest => 'Am einfachsten';

  @override
  String get importGuideDifficultyEasy => 'Einfach';

  @override
  String get importGuideDifficultyMedium => 'Mittel';

  @override
  String get importGuideTime15Sec => '15 Sek.';

  @override
  String get importGuideTime30Sec => '30 Sek.';

  @override
  String get importGuideTime1Min => '1 Min.';

  @override
  String get importGuideTime2To5Min => '2–5 Min.';

  @override
  String importGuideStepsCount(int count) {
    return '$count Schritte';
  }

  @override
  String get importGuideCategorySocial => 'Soziale Medien';

  @override
  String get importGuideCategoryWebsites => 'Webseiten';

  @override
  String get importGuideCategoryPhotos => 'Fotos & Dateien';

  @override
  String get importGuideCategoryOtherApps => 'Andere Rezepte-Apps';

  @override
  String get importGuideCategoryAi => 'AI-Import';

  @override
  String get importGuideTagNew => 'Neu';

  @override
  String get importGuideScreenshotNeeded => 'Screenshot benötigt';

  @override
  String get importGuideGifNeeded => 'GIF benötigt';

  @override
  String get importGuideVideoNeeded => 'Video benötigt';

  @override
  String get importGuideInstagramTitle => 'Instagram';

  @override
  String get importGuideInstagramSubtitle => 'Importieren aus Reels, Beiträgen und Stories';

  @override
  String get importGuideInstagramStep1Title => 'Finde einen Rezeptbeitrag oder Reel';

  @override
  String get importGuideInstagramStep1Desc => 'Öffne Instagram und finde ein Rezept, das du speichern möchtest. Funktioniert mit Feed-Beiträgen, Reels und Karussells.';

  @override
  String get importGuideInstagramStep2Title => 'Tippe auf die Teilen-Schaltfläche';

  @override
  String get importGuideInstagramStep2Desc => 'Tippe auf das Papierflieger-Symbol (Teilen) unter dem Beitrag.';

  @override
  String get importGuideInstagramStep3Title => 'An Recipe Spellbook teilen';

  @override
  String get importGuideInstagramStep3Desc => 'Scrolle durch die App-Reihe und tippe auf Recipe Spellbook. Falls nicht sichtbar, tippe auf „Mehr“ und suche sie in der Liste.';

  @override
  String get importGuideInstagramStep3Tip => 'Auf Android kannst du auch den Link kopieren und in der App einfügen.';

  @override
  String get importGuideInstagramStep4Title => 'Extrahiertes Rezept überprüfen';

  @override
  String get importGuideInstagramStep4Desc => 'Unsere KI liest die Bildunterschrift, Hashtags und jeden Text im Bild, um dein Rezept zu erstellen. Prüfe Zutaten und Schritte, dann speichere.';

  @override
  String get importGuideInstagramStep5Title => 'Kochbuch wählen & speichern';

  @override
  String get importGuideInstagramStep5Desc => 'Wähle, in welchem Kochbuch du speichern möchtest, füge Tags hinzu und tippe auf Speichern. Fertig!';

  @override
  String get importGuideTiktokTitle => 'TikTok';

  @override
  String get importGuideTiktokSubtitle => 'Rezepte aus Koch-Videos speichern';

  @override
  String get importGuideTiktokStep1Title => 'Finde ein Rezept-TikTok';

  @override
  String get importGuideTiktokStep1Desc => 'Öffne TikTok und finde ein Koch-Video, das du speichern möchtest.';

  @override
  String get importGuideTiktokStep2Title => 'Tippe auf den Teilen-Pfeil';

  @override
  String get importGuideTiktokStep2Desc => 'Tippe auf das Pfeil-Symbol rechts am Video.';

  @override
  String get importGuideTiktokStep3Title => 'Wähle „Link kopieren“ oder direkt teilen';

  @override
  String get importGuideTiktokStep3Desc => 'Tippe entweder auf „Link kopieren“ und füge ihn in Recipe Spellbook ein, oder finde Recipe Spellbook in den Teilen-Optionen.';

  @override
  String get importGuideTiktokStep3Tip => '„Link kopieren“ ist oft die zuverlässigste Methode für TikTok.';

  @override
  String get importGuideTiktokStep4Title => 'Link in Recipe Spellbook einfügen';

  @override
  String get importGuideTiktokStep4Desc => 'Öffne Recipe Spellbook, tippe auf +, wähle „Von Webseite/Link“ und füge die TikTok-URL ein.';

  @override
  String get importGuideTiktokStep5Title => 'Überprüfen & speichern';

  @override
  String get importGuideTiktokStep5Desc => 'Die KI extrahiert das Rezept aus der Videobeschreibung und den Kommentaren. Überprüfe und speichere in deinem Kochbuch.';

  @override
  String get importGuideYoutubeTitle => 'YouTube';

  @override
  String get importGuideYoutubeSubtitle => 'Importieren aus Koch-Kanälen & Shorts';

  @override
  String get importGuideYoutubeStep1Title => 'Finde ein Rezept-Video';

  @override
  String get importGuideYoutubeStep1Desc => 'Öffne YouTube und finde ein Koch-Video. Funktioniert mit normalen Videos, Shorts und Livestream-Replays.';

  @override
  String get importGuideYoutubeStep2Title => 'Tippe auf Teilen';

  @override
  String get importGuideYoutubeStep2Desc => 'Tippe auf die Teilen-Schaltfläche unter dem Videotitel.';

  @override
  String get importGuideYoutubeStep3Title => 'Link kopieren oder an App teilen';

  @override
  String get importGuideYoutubeStep3Desc => 'Tippe auf „Link kopieren“ oder finde Recipe Spellbook im Teilen-Menü.';

  @override
  String get importGuideYoutubeStep3Tip => 'Viele YouTube-Creator schreiben das vollständige Rezept in die Videobeschreibung — das macht die Extraktion genauer.';

  @override
  String get importGuideYoutubeStep4Title => 'Einfügen & importieren';

  @override
  String get importGuideYoutubeStep4Desc => 'In Recipe Spellbook tippe auf + > „Von Webseite/Link“ und füge ein. Die KI liest die Videobeschreibung für Zutaten und Schritte.';

  @override
  String get importGuidePinterestTitle => 'Pinterest';

  @override
  String get importGuidePinterestSubtitle => 'Gepinnte Rezepte in dein Kochbuch speichern';

  @override
  String get importGuidePinterestStep1Title => 'Öffne einen Rezept-Pin';

  @override
  String get importGuidePinterestStep1Desc => 'Tippe auf einen Rezept-Pin, um ihn zu öffnen. Die meisten Pins verlinken auf die Original-Rezeptseite.';

  @override
  String get importGuidePinterestStep2Title => 'Tippe auf den Quelllink';

  @override
  String get importGuidePinterestStep2Desc => 'Tippe auf den Link oben oder unten am Pin, um die Original-Rezeptseite zu besuchen.';

  @override
  String get importGuidePinterestStep2Tip => 'Falls der Pin keinen Quelllink hat, versuche stattdessen die Teilen-Methode unten.';

  @override
  String get importGuidePinterestStep3Title => 'Webseiten-URL kopieren';

  @override
  String get importGuidePinterestStep3Desc => 'Sobald die Rezeptseite in deinem Browser geöffnet ist, kopiere die URL aus der Adressleiste.';

  @override
  String get importGuidePinterestStep4Title => 'In Recipe Spellbook importieren';

  @override
  String get importGuidePinterestStep4Desc => 'Tippe auf + > „Von Webseite/Link“, füge die URL ein und das Rezept wird automatisch extrahiert.';

  @override
  String get importGuideWebsiteTitle => 'Jede Rezeptseite';

  @override
  String get importGuideWebsiteSubtitle => 'AllRecipes, Food Network, BBC, Blogs & mehr';

  @override
  String get importGuideWebsiteStep1Title => 'Öffne die Rezeptseite';

  @override
  String get importGuideWebsiteStep1Desc => 'Navigiere zu einem Rezept auf Seiten wie AllRecipes, Food Network, BBC Good Food, Serious Eats, NYT Cooking oder einem Food-Blog.';

  @override
  String get importGuideWebsiteStep2Title => 'URL kopieren';

  @override
  String get importGuideWebsiteStep2Desc => 'Tippe auf die Adressleiste und kopiere die vollständige URL zum Rezept.';

  @override
  String get importGuideWebsiteStep3Title => 'Tippe auf + in Recipe Spellbook';

  @override
  String get importGuideWebsiteStep3Desc => 'Öffne die App und tippe auf die + Schaltfläche, um ein neues Rezept hinzuzufügen.';

  @override
  String get importGuideWebsiteStep4Title => 'Wähle „Von Webseite/Link“';

  @override
  String get importGuideWebsiteStep4Desc => 'Wähle die Webseiten-Import-Option und füge deine kopierte URL ein.';

  @override
  String get importGuideWebsiteStep5Title => 'Überprüfen & speichern';

  @override
  String get importGuideWebsiteStep5Desc => 'Das Rezept wird sofort extrahiert — Titel, Zutaten, Schritte, Kochzeiten und sogar das Foto. Überprüfe und speichere.';

  @override
  String get importGuideWebsiteStep5Tip => 'Funktioniert mit über 10.000 Rezeptseiten. Falls die Extraktion fehlschlägt, versuche die „Aus Text“-Methode.';

  @override
  String get importGuidePhotoTitle => 'Foto / Kamera';

  @override
  String get importGuidePhotoSubtitle => 'Rezepte aus Büchern, Zeitschriften oder handgeschriebenen Karten scannen';

  @override
  String get importGuidePhotoStep1Title => 'Rezept fotografieren';

  @override
  String get importGuidePhotoStep1Desc => 'Mache ein klares, gut beleuchtetes Foto eines Rezepts aus einem Kochbuch, einer Zeitschrift oder einer handgeschriebenen Rezeptkarte. Stelle sicher, dass der gesamte Text lesbar ist.';

  @override
  String get importGuidePhotoStep1Tip => 'Für beste Ergebnisse: gute Beleuchtung, ruhig halten und das gesamte Rezept im Bild haben. Schatten vermeiden.';

  @override
  String get importGuidePhotoStep2Title => 'Tippe auf + dann „Von Foto“';

  @override
  String get importGuidePhotoStep2Desc => 'Öffne Recipe Spellbook, tippe auf + und wähle „Von Foto“. Wähle das Foto aus deiner Galerie oder mache ein neues.';

  @override
  String get importGuidePhotoStep3Title => 'KI scannt den Text';

  @override
  String get importGuidePhotoStep3Desc => 'OCR-Technologie liest den Text in deinem Foto und KI trennt intelligent Titel, Zutaten und Anleitung.';

  @override
  String get importGuidePhotoStep4Title => 'Überprüfen & Fehler beheben';

  @override
  String get importGuidePhotoStep4Desc => 'Prüfe das extrahierte Rezept. OCR liest gelegentlich Zeichen falsch — „1/2“ könnte zu „1l2“ werden. Behebe Fehler und speichere.';

  @override
  String get importGuidePhotoStep4Tip => 'Handgeschriebene Rezepte funktionieren auch, aber gedruckter Text liefert die besten Ergebnisse.';

  @override
  String get importGuidePdfTitle => 'PDF-Dokument';

  @override
  String get importGuidePdfSubtitle => 'Importieren aus PDF-Kochbüchern oder Downloads';

  @override
  String get importGuidePdfStep1Title => 'Eine Rezept-PDF bereithalten';

  @override
  String get importGuidePdfStep1Desc => 'Funktioniert mit heruntergeladenen Rezept-PDFs, E-Book-Kochbüchern, gescannten Dokumenten oder per E-Mail geteilten PDFs.';

  @override
  String get importGuidePdfStep2Title => 'Tippe auf + dann „Aus PDF“';

  @override
  String get importGuidePdfStep2Desc => 'Öffne Recipe Spellbook, tippe auf +, wähle „Aus PDF“ und wähle deine Datei.';

  @override
  String get importGuidePdfStep3Title => 'Rezeptseite auswählen';

  @override
  String get importGuidePdfStep3Desc => 'Falls die PDF mehrere Seiten hat, wähle die Seite mit dem Rezept, das du importieren möchtest.';

  @override
  String get importGuidePdfStep4Title => 'Überprüfen & speichern';

  @override
  String get importGuidePdfStep4Desc => 'Das Rezept wird aus der PDF extrahiert. Überprüfe die Zutaten und Schritte, dann speichere in deinem Kochbuch.';

  @override
  String get importGuideTextTitle => 'Text / Einfügen';

  @override
  String get importGuideTextSubtitle => 'Rezept aus Nachrichten, E-Mail oder Notizen einfügen';

  @override
  String get importGuideTextStep1Title => 'Rezepttext kopieren';

  @override
  String get importGuideTextStep1Desc => 'Kopiere den Rezepttext aus einer SMS, E-Mail, Notiz-App, WhatsApp oder anderswo.';

  @override
  String get importGuideTextStep2Title => 'Tippe auf + dann „Aus Text“';

  @override
  String get importGuideTextStep2Desc => 'Öffne Recipe Spellbook, tippe auf + und wähle „Aus Text“.';

  @override
  String get importGuideTextStep3Title => 'Dein Rezept einfügen';

  @override
  String get importGuideTextStep3Desc => 'Füge den kopierten Text in das Textfeld ein. Die KI trennt automatisch Titel, Zutaten und Schritte.';

  @override
  String get importGuideTextStep3Tip => 'Funktioniert auch mit unformatiertem Text — die KI ist intelligent beim Erkennen von Zutatenmengen und Schrittanweisungen.';

  @override
  String get importGuideTextStep4Title => 'Überprüfen & speichern';

  @override
  String get importGuideTextStep4Desc => 'Prüfe das analysierte Rezept, nimm Anpassungen vor und speichere.';

  @override
  String get importGuideAiTitle => 'AI (ChatGPT, Claude usw.)';

  @override
  String get importGuideAiSubtitle => 'Erstelle Rezepte mit AI und importiere sie sofort';

  @override
  String get importGuideAiStep1Title => 'AI-Import öffnen';

  @override
  String get importGuideAiStep1Desc => 'Gehe zur Startseite, tippe auf +, um ein Rezept hinzuzufügen, wähle Import und tippe dann auf die AI-Taste.';

  @override
  String get importGuideAiStep2Title => 'Prompt kopieren';

  @override
  String get importGuideAiStep2Desc => 'Tippe auf den Prompt-Kopieren-Button. Öffne dann deine bevorzugte AI — ChatGPT, Claude, Gemini oder andere — und füge den Prompt ein.';

  @override
  String get importGuideAiStep3Title => 'AI-Antwort kopieren';

  @override
  String get importGuideAiStep3Desc => 'Die AI generiert ein Rezept im JSON-Format. Kopiere die gesamte Antwort.';

  @override
  String get importGuideAiStep4Title => 'In Recipe Spellbook einfügen';

  @override
  String get importGuideAiStep4Desc => 'Gehe zurück zu Recipe Spellbook, tippe auf Einfügen, dann auf Vorschau, um das verarbeitete Rezept zu sehen.';

  @override
  String get importGuideAiStep5Title => 'Vorschau & Import';

  @override
  String get importGuideAiStep5Desc => 'Prüfe, ob alles korrekt aussieht, und tippe dann auf Importieren, um das Rezept zu speichern.';

  @override
  String get importGuideOtherAppsTitle => 'Andere Rezepte-Apps';

  @override
  String get importGuideOtherAppsSubtitle => 'Mealime, CopyMeThat, AnyList, Cookmate usw.';

  @override
  String get importGuideOtherAppsStep1Title => 'Aus deiner aktuellen App exportieren';

  @override
  String get importGuideOtherAppsStep1Desc => 'Die meisten Rezepte-Apps unterstützen Export als JSON, HTML oder Text. Prüfe Einstellungen > Exportieren oder Backup.';

  @override
  String get importGuideOtherAppsStep1Tip => 'Gängige Formate: JSON (am besten), HTML, PDF oder Klartext. JSON bewahrt die meisten Daten.';

  @override
  String get importGuideOtherAppsStep2Title => 'Datei auf dein Gerät übertragen';

  @override
  String get importGuideOtherAppsStep2Desc => 'Speichere oder übertrage die exportierte Datei per E-Mail, Cloud-Speicher oder einer Dateiübertragungsmethode auf dein Handy.';

  @override
  String get importGuideOtherAppsStep3Title => 'Über Einstellungen importieren';

  @override
  String get importGuideOtherAppsStep3Desc => 'Gehe in Recipe Spellbook zu Einstellungen > Daten > Importieren und wähle die exportierte Datei. Die App verarbeitet JSON, HTML und gängige Rezeptformate.';

  @override
  String get importGuideOtherAppsStep4Title => 'Rezepte überprüfen';

  @override
  String get importGuideOtherAppsStep4Desc => 'Importierte Rezepte erscheinen in deinem Standard-Kochbuch. Du kannst sie danach in verschiedene Kochbücher verschieben.';

  @override
  String get importGuideDeviceTransferTitle => 'Geräteübertragung';

  @override
  String get importGuideDeviceTransferSubtitle => 'Rezepte zwischen Handys übertragen ohne Konto';

  @override
  String get importGuideDeviceTransferStep1Title => 'Übertragung auf dem ALTEN Gerät öffnen';

  @override
  String get importGuideDeviceTransferStep1Desc => 'Öffne auf deinem alten Handy Recipe Spellbook und gehe zu Menü > Geräteübertragung > Senden.';

  @override
  String get importGuideDeviceTransferStep2Title => 'Übertragungscode erhalten';

  @override
  String get importGuideDeviceTransferStep2Desc => 'Ein 6-stelliger Code wird generiert. Dieser Code ist 15 Minuten gültig.';

  @override
  String get importGuideDeviceTransferStep3Title => 'Code auf dem NEUEN Gerät eingeben';

  @override
  String get importGuideDeviceTransferStep3Desc => 'Installiere auf deinem neuen Handy Recipe Spellbook und gehe zu Menü > Geräteübertragung > Empfangen. Gib den Code ein.';

  @override
  String get importGuideDeviceTransferStep4Title => 'Rezepte übertragen!';

  @override
  String get importGuideDeviceTransferStep4Desc => 'Alle deine Rezepte, Kochbücher, Einkaufslisten und Essenspläne werden auf das neue Gerät übertragen.';

  @override
  String get importGuideDeviceTransferStep4Tip => 'Ein kostenpflichtiges Konto? Melde dich einfach auf dem neuen Gerät an und alles wird automatisch synchronisiert.';

  @override
  String get faqTitle => 'FAQ';

  @override
  String get faqHeroTitle => 'Häufig gestellte Fragen';

  @override
  String get faqHeroSubtitle => 'Finde Antworten und Schritt-für-Schritt-Anleitungen für häufige Funktionen.';

  @override
  String get faqHowToGuides => 'Anleitungen';

  @override
  String get faqCommonQuestions => 'Häufige Fragen';

  @override
  String get faqSeeHowTo => 'Anleitung ansehen';

  @override
  String faqStepsCount(int count) {
    return '$count Schritte';
  }

  @override
  String get faqAddHeadersTitle => 'Überschriften hinzufügen';

  @override
  String get faqAddHeadersSubtitle => 'Organisiere Zutaten und Schritte in Abschnitte';

  @override
  String get faqAddHeadersStep1Title => 'Rezepteditor öffnen';

  @override
  String get faqAddHeadersStep1Desc => 'Öffne ein Rezept und tippe auf das Bearbeiten-Symbol.';

  @override
  String get faqAddHeadersStep2Title => 'Überschrift hinzufügen';

  @override
  String get faqAddHeadersStep2Desc => 'Tippe auf „Überschrift hinzufügen“, um eine Abschnittsüberschrift einzufügen.';

  @override
  String get faqAddHeadersStep3Title => 'Überschrift-Menü öffnen';

  @override
  String get faqAddHeadersStep3Desc => 'Tippe auf die drei Punkte (⋮) neben der Überschrift für weitere Optionen.';

  @override
  String get faqAddHeadersStep4Title => 'Überschriften neu anordnen';

  @override
  String get faqAddHeadersStep4Desc => 'Tippe auf Sortierreihenfolge, um die Anordnung zu ändern. Ziehe den ≡-Griff, um Überschriften zu verschieben.';

  @override
  String get faqAddHeadersStep4Tip => 'Du kannst Überschriften ziehen, indem du den ≡-Griff (zwei Linien) auf der linken Seite gedrückt hältst.';

  @override
  String get faqAddHeadersStep5Title => 'Änderungen speichern';

  @override
  String get faqAddHeadersStep5Desc => 'Tippe auf Speichern, um die neuen Überschriften zu behalten.';

  @override
  String get faqAddHeadersStep6Title => 'Fertig!';

  @override
  String get faqAddHeadersStep6Desc => 'Dein Rezept hat jetzt übersichtliche Abschnitte mit Überschriften.';

  @override
  String get faqAddSublinkedTitle => 'Verknüpfte Rezepte hinzufügen';

  @override
  String get faqAddSublinkedSubtitle => 'Verknüpfe verwandte Rezepte für schnellen Zugriff';

  @override
  String get faqAddSublinkedStep1Title => 'Rezepteditor öffnen';

  @override
  String get faqAddSublinkedStep1Desc => 'Öffne ein Rezept und tippe auf das Bearbeiten-Symbol.';

  @override
  String get faqAddSublinkedStep2Title => 'Menü öffnen';

  @override
  String get faqAddSublinkedStep2Desc => 'Tippe auf die drei Punkte (⋮) im Bearbeitungsbildschirm.';

  @override
  String get faqAddSublinkedStep3Title => 'Rezept verknüpfen antippen';

  @override
  String get faqAddSublinkedStep3Desc => 'Wähle „Rezept verknüpfen“ aus dem Menü.';

  @override
  String get faqAddSublinkedStep4Title => 'Rezept zum Verknüpfen wählen';

  @override
  String get faqAddSublinkedStep4Desc => 'Tippe auf das Verknüpfungssymbol neben dem Rezept, das du verbinden möchtest (z.B. Pizzateig).';

  @override
  String get faqAddSublinkedStep5Title => 'Änderungen speichern';

  @override
  String get faqAddSublinkedStep5Desc => 'Tippe auf Speichern, um das verknüpfte Rezept zu behalten.';

  @override
  String get faqAddSublinkedStep6Title => 'Fertig!';

  @override
  String get faqAddSublinkedStep6Desc => 'Das verknüpfte Rezept erscheint jetzt in deinem Rezept und kann angetippt werden.';

  @override
  String get faqWhatAreHeadersTitle => 'Was sind Überschriften?';

  @override
  String get faqWhatAreHeadersSubtitle => 'Rezepte in Abschnitte organisieren';

  @override
  String get faqWhatAreHeadersAnswer => 'Mit Überschriften kannst du Zutaten und Schritte in Abschnitte unterteilen. Du könntest z.B. separate Abschnitte für „Soße“, „Teig“ und „Belag“ in einem Pizzarezept haben. Sie machen lange Rezepte viel übersichtlicher.';

  @override
  String get faqWhatAreSublinkedTitle => 'Was sind verknüpfte Rezepte?';

  @override
  String get faqWhatAreSublinkedSubtitle => 'Verwandte Rezepte verbinden';

  @override
  String get faqWhatAreSublinkedAnswer => 'Verknüpfte Rezepte verbinden verwandte Rezepte miteinander. Zum Beispiel kann ein Margherita-Pizza-Rezept mit deinem Pizzateig-Rezept verknüpft werden. Beim Ansehen des Hauptrezepts kannst du auf das verknüpfte Rezept tippen, um direkt dorthin zu springen.';

  @override
  String get faqMacroCalcTitle => 'So nutzt du den Makro-Rechner';

  @override
  String get faqMacroCalcSubtitle => 'Kalorien und Makros für jedes Rezept automatisch berechnen';

  @override
  String get faqMacroCalcStep1Title => 'Öffne ein Rezept';

  @override
  String get faqMacroCalcStep1Desc => 'Öffne ein beliebiges Rezept und scrolle zum Abschnitt Nährwerte.';

  @override
  String get faqMacroCalcStep2Title => 'Tippe zum Berechnen';

  @override
  String get faqMacroCalcStep2Desc => 'Tippe auf den leeren Nährwertbereich, um den Rechner zu öffnen. Dort steht „Zum Berechnen tippen“.';

  @override
  String get faqMacroCalcStep3Title => 'Automatische Analyse';

  @override
  String get faqMacroCalcStep3Desc => 'Der Rechner gleicht deine Zutaten automatisch mit der USDA-Lebensmitteldatenbank ab und berechnet Kalorien, Protein, Kohlenhydrate, Fett und mehr.';

  @override
  String get faqMacroCalcStep4Title => 'Manuell eingeben';

  @override
  String get faqMacroCalcStep4Desc => 'Tippe auf „Manuell eingeben“, um Nährwerte von Hand zu bearbeiten, wenn du eigene Daten eingeben möchtest.';

  @override
  String get faqMacroCalcStep5Title => 'Zutatenzuordnungen prüfen';

  @override
  String get faqMacroCalcStep5Desc => 'Scrolle nach unten, um jede Zutat zu sehen, die einem USDA-Lebensmittel zugeordnet wurde. Verlinkte Rezepte (wie Pizzateig) verwenden ihre eigenen gespeicherten Nährwerte.';

  @override
  String get faqMacroCalcStep5Tip => 'Nicht sicher, was ein verlinktes Rezept ist? Schau in den FAQ-Bereich „Was sind verlinkte Rezepte?“!';

  @override
  String get faqMacroCalcStep6Title => 'USDA-Datenbank durchsuchen';

  @override
  String get faqMacroCalcStep6Desc => 'Tippe auf eine Zutat, um die USDA-Datenbank nach einer besseren Zuordnung zu durchsuchen.';

  @override
  String get faqMacroCalcStep7Title => 'Nährwerte verlinkter Rezepte';

  @override
  String get faqMacroCalcStep7Desc => 'Zutaten, die mit anderen Rezepten verlinkt sind, zeigen die Nährwerte des verlinkten Rezepts. Du kannst den Faktor anpassen.';

  @override
  String get faqMacroCalcStep8Title => 'Ergebnisse speichern';

  @override
  String get faqMacroCalcStep8Desc => 'Tippe auf Speichern, um die Nährwertdaten zu sichern. Die Makros erscheinen nun auf deinem Rezept mit Diagrammen und detaillierten Aufschlüsselungen pro Portion.';

  @override
  String get faqMacroCalcStep9Title => 'Anzeige anpassen';

  @override
  String get faqMacroCalcStep9Desc => 'Gehe zu Einstellungen > Nährwertanzeige, um auszuwählen, welche Nährstoffe angezeigt werden und wie die Diagramme dargestellt werden.';

  @override
  String get faqWhatIsMacroCalcTitle => 'Was ist der Makro-Rechner?';

  @override
  String get faqWhatIsMacroCalcSubtitle => 'Automatische Nährwertschätzung für Rezepte';

  @override
  String get faqWhatIsMacroCalcAnswer => 'Der Makro-Rechner schätzt automatisch den Nährstoffgehalt deiner Rezepte, indem jede Zutat mit der USDA-Lebensmitteldatenbank abgeglichen wird. Er berechnet Kalorien, Protein, Kohlenhydrate, Fett, Ballaststoffe, Zucker, Natrium und mehr – alles pro Portion. Du findest ihn im Abschnitt Nährwerte bei jedem Rezept.';

  @override
  String get faqImportFailedTitle => 'Warum ist mein Import fehlgeschlagen?';

  @override
  String get faqImportFailedSubtitle => 'Häufige Ursachen und Lösungen';

  @override
  String get faqImportFailedAnswer => 'Importe können aus mehreren Gründen fehlschlagen:\n\n• Die Website blockiert möglicherweise den automatischen Zugriff — versuche, den Rezepttext zu kopieren und den Textimport zu verwenden.\n• Der Link ist möglicherweise abgelaufen oder privat — stelle sicher, dass er öffentlich ist.\n• Manche Seiten verwenden schwer zu lesende Formate — versuche den AI-Import.\n• Prüfe deine Internetverbindung und versuche es erneut.';

  @override
  String get faqDeviceTransferTitle => 'Kann ich von anderen Geräten importieren?';

  @override
  String get faqDeviceTransferSubtitle => 'Rezepte zwischen Geräten übertragen';

  @override
  String get faqDeviceTransferAnswer => 'Ja! Nutze die Gerätetransfer-Funktion unter Einstellungen > Daten > Gerätetransfer. Generiere einen Code auf deinem alten Gerät und gib ihn auf dem neuen ein. Alle Rezepte, Kochbücher und Bilder werden übertragen.';

  @override
  String get themeFrost => 'Frost';

  @override
  String get themeEmber => 'Glut';

  @override
  String get themeSpring => 'Frühling';

  @override
  String get themeAlchemist => 'Alchemist';

  @override
  String get themeMatcha => 'Matcha';

  @override
  String get themeCustom => 'Benutzerdefiniert';

  @override
  String get communitySortTopRated => 'Bestbewertet';

  @override
  String get communityHasImages => 'Mit Bildern';

  @override
  String get communityListView => 'Listenansicht';

  @override
  String get communityGridView => 'Rasteransicht';

  @override
  String get communityDownloadOptions => 'Download-Optionen';

  @override
  String communityDownloadWithImages(String size) {
    return 'Mit Bildern ($size)';
  }

  @override
  String communityDownloadImagesIncluded(int count) {
    return '$count Bilder enthalten';
  }

  @override
  String get communityDownloadTextOnly => 'Nur Text';

  @override
  String get communityDownloadTextOnlySubtitle => 'Schnellerer Download, keine Bilder';

  @override
  String get communityTapToPreview => 'Tippe auf ein Rezept zur Vorschau';

  @override
  String communityImageCountLabel(int count) {
    return '$count Bilder';
  }

  @override
  String get communityYourRating => 'Deine Bewertung:';

  @override
  String get communityRateThis => 'Dieses Kochbuch bewerten:';

  @override
  String communityDownloadingImages(int current, int total) {
    return 'Bilder werden heruntergeladen... $current/$total';
  }

  @override
  String get communityViewFullRecipe => 'Vollständiges Rezept anzeigen';

  @override
  String communityMoreIngredients(int count) {
    return '+ $count weitere';
  }

  @override
  String communityStepCount(int count) {
    return '$count Schritte';
  }

  @override
  String get communityNotes => 'Notizen';

  @override
  String get communityStatPrep => 'Vorbereitung';

  @override
  String get communityStatCook => 'Kochen';

  @override
  String get communityStatTotal => 'Gesamt';

  @override
  String get communityStatServings => 'Portionen';

  @override
  String communityStepDuration(int minutes) {
    return '$minutes Min.';
  }

  @override
  String get communityEditPublication => 'Veröffentlichung bearbeiten';

  @override
  String get communityEditDescription => 'Beschreibung';

  @override
  String get communityEditDescriptionHint => 'Erzähle anderen über dieses Kochbuch...';

  @override
  String get communityEditTags => 'Tags';

  @override
  String get communityEditSuccess => 'Veröffentlichung aktualisiert!';

  @override
  String get communityEditFailed => 'Aktualisierung der Veröffentlichung fehlgeschlagen';

  @override
  String get communityNoRatingsYet => 'Noch keine Bewertungen';

  @override
  String get communityStatusPublished => 'Veröffentlicht';

  @override
  String get communityStatusUnderReview => 'Wird überprüft';

  @override
  String get communityStatusRemoved => 'Entfernt';

  @override
  String get communityUnderReview => 'Dieses Kochbuch wird von unserem Moderationsteam überprüft.';

  @override
  String get communityPublishPreparing => 'Kochbuch wird vorbereitet...';

  @override
  String communityPublishUploading(int current, int total) {
    return 'Bilder werden hochgeladen ($current/$total)';
  }

  @override
  String get communityPublishPublishing => 'Wird in der Community veröffentlicht...';

  @override
  String get communityPublishBackground => 'Du kannst diesen Bildschirm verlassen – die Veröffentlichung läuft im Hintergrund weiter.';

  @override
  String get communityPublishDone => 'Veröffentlicht!';

  @override
  String communityPublishImagesSkipped(int count) {
    return '$count Bilder wurden übersprungen (von der Moderation abgelehnt)';
  }

  @override
  String communityPublishRejected(int count) {
    return '$count von der Moderation abgelehnt';
  }

  @override
  String get communityConfigurePublication => 'Veröffentlichung konfigurieren';

  @override
  String get communityPublishTitle => 'Titel';

  @override
  String get communityPublishTitleHint => 'Kochbuchtitel';

  @override
  String get communityPublishDescription => 'Beschreibung';

  @override
  String get communityPublishDescriptionHint => 'Erzähle anderen über dieses Kochbuch...';

  @override
  String get communityPublishTags => 'Tags';

  @override
  String get communityPublishIncludeImages => 'Bilder einschließen';

  @override
  String get communityPublishIncludeImagesSubtitle => 'Rezeptbilder mit diesem Kochbuch hochladen. Bilder werden auf Sicherheit geprüft.';

  @override
  String get communityPublishSummary => 'Zusammenfassung';

  @override
  String communityPublishRecipesSummary(int count) {
    return '$count Rezepte';
  }

  @override
  String get communityPublishImagesWillUpload => 'Bilder werden hochgeladen';

  @override
  String get communityPublishTextOnlyNoImages => 'Nur Text (keine Bilder)';

  @override
  String get communityPublishTryAgain => 'Erneut versuchen';

  @override
  String communityPublishUploadInProgress(int current, int total) {
    return 'Veröffentlichung läuft... ($current/$total Bilder)';
  }

  @override
  String get surpriseMeTitle => 'Überrasch mich!';

  @override
  String get surpriseMeSubtitle => 'Was soll ich kochen?';

  @override
  String get hintNutritionCalculator => 'Wusstest du? Tippe auf das Nährwert-Symbol, um die Nährwerte für jedes Rezept automatisch zu berechnen.';

  @override
  String get hintCookingScreen => 'Probiere den Kochmodus! Tippe bei einem Rezept auf \'Kochen\' für eine freihändige Schritt-für-Schritt-Anleitung.';

  @override
  String get hintIngredientHeaders => 'Tipp: Tippe eine Zeile mit \':\' am Ende bei den Zutaten ein, um eine Abschnittsüberschrift zu erstellen.';

  @override
  String get hintImportMethods => 'Importiere Rezepte von URLs, Fotos, PDFs oder sogar Instagram und TikTok!';

  @override
  String get hintMealPlanAutoFill => 'Ziehe Rezepte in deinen Essensplan oder tippe auf einen Tag, um aus deiner Sammlung auszuwählen.';

  @override
  String get hintRecipeScaling => 'Tippe auf die Portionszahl bei einem Rezept, um die Zutaten hoch- oder runterzurechnen.';

  @override
  String get hintShoppingListGen => 'Füge Rezeptzutaten mit einem Tipp zu deiner Einkaufsliste hinzu.';

  @override
  String get hintRecipeNotes => 'Füge persönliche Notizen zu jedem Rezept hinzu – Tipps, Änderungen oder Erinnerungen.';

  @override
  String get hintCookbookOrganization => 'Erstelle mehrere Kochbücher, um deine Rezepte nach Thema oder Anlass zu ordnen.';

  @override
  String get hintTagSystem => 'Tagge Rezepte für einfaches Filtern – erstelle eigene Tags wie \'Schnell\', \'Favorit\' usw.';

  @override
  String get allergyMyAllergies => 'Meine Allergien';

  @override
  String get allergyDisabledTab => 'Deaktiviert';

  @override
  String get allergyNoDisabledTitle => 'Keine deaktivierten Warnungen';

  @override
  String get allergyNoDisabledSubtitle => 'Wenn du Allergiewarnungen bei Rezepten ausblendet, erscheinen sie hier, damit du sie wiederherstellen kannst.';

  @override
  String get allergyDisabledInfo => 'Bei diesen Rezepten wurden die Allergiewarnungen deaktiviert. Tippe zum Wiederherstellen.';

  @override
  String trashRestoredMessage(String title) {
    return '\"$title\" wiederhergestellt';
  }

  @override
  String get nutrientCalories => 'Kalorien';

  @override
  String get nutrientTotalFat => 'Gesamtfett';

  @override
  String get nutrientSaturatedFat => 'Gesättigtes Fett';

  @override
  String get nutrientTransFat => 'Transfett';

  @override
  String get nutrientMonounsaturatedFat => 'Einfach ungesättigtes Fett';

  @override
  String get nutrientPolyunsaturatedFat => 'Mehrfach ungesättigtes Fett';

  @override
  String get nutrientCarbohydrates => 'Kohlenhydrate';

  @override
  String get nutrientFiber => 'Ballaststoffe';

  @override
  String get nutrientSugars => 'Zucker';

  @override
  String get nutrientProtein => 'Protein';

  @override
  String get nutrientCholesterol => 'Cholesterin';

  @override
  String get nutrientSodium => 'Natrium';

  @override
  String get nutrientPotassium => 'Kalium';

  @override
  String get nutrientCalcium => 'Kalzium';

  @override
  String get nutrientIron => 'Eisen';

  @override
  String get nutrientMagnesium => 'Magnesium';

  @override
  String get nutrientPhosphorus => 'Phosphor';

  @override
  String get nutrientZinc => 'Zink';

  @override
  String get nutrientCopper => 'Kupfer';

  @override
  String get nutrientManganese => 'Mangan';

  @override
  String get nutrientSelenium => 'Selen';

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
  String get nutrientPantothenicAcidB5 => 'Pantothensäure (B5)';

  @override
  String get nutrientVitaminB6 => 'Vitamin B6';

  @override
  String get nutrientVitaminB12 => 'Vitamin B12';

  @override
  String get nutrientFolate => 'Folat';

  @override
  String get nutrientCholine => 'Cholin';

  @override
  String get nutrientCategoryMacronutrients => 'Makronährstoffe';

  @override
  String get nutrientCategoryMinerals => 'Mineralstoffe';

  @override
  String get nutrientCategoryVitamins => 'Vitamine';

  @override
  String get nutrientCarbs => 'Kohlenhydrate';

  @override
  String get nutrientFat => 'Fett';

  @override
  String nutritionKcalPerServing(int count) {
    return '$count kcal pro Portion';
  }

  @override
  String nutritionKcalTotal(int count) {
    return '$count kcal gesamt';
  }

  @override
  String get shareShoppingList => 'Einkaufsliste teilen';

  @override
  String get shareOneTimeLink => 'Einmaliger Link';

  @override
  String get shareOneTimeLinkSubtitle => 'Kostenlos • 24 Std. gültig • Nur ansehen/herunterladen';

  @override
  String get shareGenerateLink => 'Link erstellen';

  @override
  String get shareFamilyShare => 'Familienfreigabe';

  @override
  String get shareFamilySyncSubtitle => 'Echtzeit-Sync · Berechtigungen pro Mitglied';

  @override
  String get shareFamilyCreateJoin => 'Erstelle oder trete einer Familie bei, um zu teilen';

  @override
  String get shareFamilyRequiresCloudSync => 'Erfordert Cloud-Sync-Abonnement';

  @override
  String get shareFamilyUpgradeMessage => 'Upgrade auf Cloud Sync, um Kochbücher und Listen in Echtzeit mit deiner Familie zu teilen.';

  @override
  String get shareFamilySignIn => 'Anmelden, um Familienfreigabe zu nutzen';

  @override
  String get shareFamilySetupInSettings => 'Erstelle oder trete einer Familie bei unter Einstellungen → Familienfreigabe';

  @override
  String get shareSharedWith => 'Geteilt mit';

  @override
  String get shareRevoked => 'Freigabe widerrufen';

  @override
  String get shareSignInRequired => 'Anmelden, um Teilen-Links zu erstellen';

  @override
  String get shareCreateFailed => 'Link konnte nicht erstellt werden';

  @override
  String get shareNoFamilyMembers => 'Keine anderen Familienmitglieder zum Teilen';

  @override
  String get shareAddFamilyMembers => 'Familienmitglieder hinzufügen';

  @override
  String get shareWith => 'Teilen mit';

  @override
  String shareSharedWithMember(String name) {
    return 'Geteilt mit $name';
  }

  @override
  String get shareShareFailed => 'Teilen fehlgeschlagen';

  @override
  String get shareLinkCopied => 'Link kopiert!';

  @override
  String shareLinkExpiresIn(int hours) {
    return 'Läuft ab in $hours Std.';
  }

  @override
  String get shareRevoke => 'Widerrufen';

  @override
  String get shareUpgrade => 'Upgrade';

  @override
  String get sharePermReadOnly => 'Nur lesen';

  @override
  String get sharePermAddOnly => 'Nur hinzufügen';

  @override
  String get sharePermFullEdit => 'Vollständig bearbeiten';

  @override
  String get sharePermFullAccess => 'Vollzugriff';

  @override
  String get sharePermViewRecipes => 'Kann Rezepte ansehen';

  @override
  String get sharePermAddRecipes => 'Kann neue Rezepte hinzufügen';

  @override
  String get sharePermEditRecipes => 'Kann jedes Rezept bearbeiten';

  @override
  String get sharePermViewItems => 'Kann Einträge ansehen';

  @override
  String get sharePermAddItems => 'Kann Einträge hinzufügen, eigene bearbeiten';

  @override
  String get sharePermEditItems => 'Kann Einträge bearbeiten und löschen';

  @override
  String get shareUnknownMember => 'Unbekannt';

  @override
  String get subscriptionTitle => 'Abonnement';

  @override
  String get subscriptionUpgradeToPro => 'Auf Pro upgraden';

  @override
  String get subscriptionUnlockFeatures => 'Cloud-Sync, smarten Import und mehr freischalten.';

  @override
  String get subscriptionViewPlans => 'Pläne ansehen';

  @override
  String get subscriptionRestored => 'Käufe erfolgreich wiederhergestellt!';

  @override
  String get subscriptionNoPurchases => 'Keine früheren Käufe gefunden.';

  @override
  String subscriptionRestoreFailed(String error) {
    return 'Wiederherstellung fehlgeschlagen: $error';
  }

  @override
  String get subscriptionRestorePurchases => 'Käufe wiederherstellen';

  @override
  String subscriptionCancelledUntil(String date) {
    return 'Gekündigt — Zugriff bis $date';
  }

  @override
  String get subscriptionRenews => 'Verlängert sich';

  @override
  String get subscriptionPlan => 'Abo';

  @override
  String get subscriptionLifetime => 'Lebenslang — läuft nie ab';

  @override
  String get subscriptionManage => 'Abonnement verwalten';

  @override
  String get subscriptionUnknownDate => 'Unbekannt';

  @override
  String get subscriptionUpgradeToUnlock => 'Auf Pro upgraden zum Freischalten';

  @override
  String get subscriptionProBadge => 'PRO';

  @override
  String get customThemeTitle => 'Benutzerdefiniertes Theme';

  @override
  String get customThemeColors => 'Farben';

  @override
  String get customThemeBackground => 'Hintergrund';

  @override
  String get customThemeBackgroundDesc => 'App-Hintergrund, Gerüst';

  @override
  String get customThemePrimary => 'Primär';

  @override
  String get customThemePrimaryDesc => 'Schaltflächen, Hervorhebungen, App-Leiste';

  @override
  String get customThemeAccent => 'Akzent';

  @override
  String get customThemeAccentDesc => 'FAB, Schalter, sekundäre Hervorhebungen';

  @override
  String get customThemeStartFromPreset => 'Von einer Vorlage starten';

  @override
  String get customThemeLightMode => 'Hell';

  @override
  String get customThemeDarkMode => 'Dunkel';

  @override
  String customThemeLinkedOverlay(String mode) {
    return 'Farben werden automatisch aus Ihrem $mode-Design generiert';
  }

  @override
  String get customThemeUnlockButton => 'Farben anpassen';

  @override
  String customThemeLinkButton(String mode) {
    return 'Mit $mode verknüpfen';
  }

  @override
  String get customThemeLivePreview => 'Live-Vorschau';

  @override
  String get settingsUserFallback => 'Benutzer';

  @override
  String get settingsManageSection => 'Verwalten';

  @override
  String get settingsExportNone => 'Keine ausgewählt';

  @override
  String get settingsExportPartial => 'Teilweise Sicherung';

  @override
  String get settingsSystemLanguage => 'System';

  @override
  String get tierFamily => 'FAMILY';

  @override
  String get tierCreator => 'CREATOR';

  @override
  String get tierFreeName => 'Kostenlos';

  @override
  String get tierPremiumName => 'Premium';

  @override
  String get tierCloudSyncName => 'Cloud Sync';

  @override
  String get tierCloudSyncFamilyName => 'Cloud Sync Familie';

  @override
  String get tierCreatorName => 'Creator';

  @override
  String get nutritionEstimated => 'Geschätzte Werte';

  @override
  String get nutritionTipMatch => 'Tippe auf eine Zutat, um die USDA-Zuordnung zu ändern';

  @override
  String get nutritionTipManual => 'Genaue Nährwerte eingeben, wenn du sie kennst';

  @override
  String get nutritionTipSpecific => 'Wähle spezifische Sorten (z. B. „Weizenmehl Typ 405“ statt nur „Mehl“)';

  @override
  String get nutritionTipSaved => 'Deine Korrekturen werden für zukünftige Rezepte gespeichert';

  @override
  String get nutritionGotIt => 'Verstanden';

  @override
  String get nutritionScaleMultiplier => 'Skalierungsfaktor';

  @override
  String get nutritionScaleHelper => '1,0 = ganzes Rezept';

  @override
  String nutritionOpenRecipe(String title) {
    return '$title öffnen';
  }

  @override
  String get nutrientCal => 'kcal';

  @override
  String get nutrientSugar => 'Zucker';

  @override
  String get appearanceCustomThemeRequiresPremium => 'Benutzerdefiniertes Theme erfordert Premium';

  @override
  String get appearancePremiumBadge => 'Premium';

  @override
  String get substitutionsAll => 'Alle';

  @override
  String substitutionsCount(int count, String category) {
    return '$count Alternativen • $category';
  }

  @override
  String get colorPickerTitle => 'Farbe auswählen';

  @override
  String get colorPickerHex => 'Hex';

  @override
  String get colorPickerSelect => 'Auswählen';

  @override
  String get scanSelectPages => 'Mehrere Seiten auswählen';

  @override
  String get scanNoTextPdf => 'Kein Text im PDF gefunden. Versuche einen klareren Scan oder die Text-Einfügen-Option.';

  @override
  String scanLittleTextPdf(int count) {
    return 'Sehr wenig Text im PDF erkannt ($count Zeichen). Der Scan ist möglicherweise zu unscharf. Versuche ein besseres PDF oder nutze stattdessen die Text-Einfügen-Option.';
  }

  @override
  String get scanNoTextImage => 'Kein Text im Bild gefunden. Versuche das Foto bei besserer Beleuchtung aufzunehmen oder nutze stattdessen die Text-Einfügen-Option.';

  @override
  String scanLittleTextImage(int count) {
    return 'Sehr wenig Text erkannt ($count Zeichen). Versuche ein klareres Foto mit besserer Beleuchtung oder nutze stattdessen die Text-Einfügen-Option.';
  }

  @override
  String scanProgress(int current, int total) {
    return 'Scanne Seite $current von $total...';
  }

  @override
  String get communityTagHint => 'Eigenen Tag hinzufügen...';

  @override
  String get tagPickerOrganize => 'Tags helfen dir, deine Rezepte zu organisieren';

  @override
  String get tagPickerLoadDefaults => 'Standard-Tags laden';

  @override
  String get tagPickerExampleHint => 'z. B. Date Night';

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
}
