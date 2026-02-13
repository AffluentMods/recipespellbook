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
  String get settingsRPGMode => 'RPG-Modus';

  @override
  String get settingsRPGModeSubtitle => 'Fantasy-Texte und -Bilder aktivieren';

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
  String importingRecipes(int count) {
    return 'Importiere $count Rezepte...';
  }

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
  String get defaultImagesDescription => 'App-Grafiken, die sich mit dem RPG-Modus ändern';

  @override
  String get themeBased => 'Themenbasiert';

  @override
  String get themeBasedDescription => 'Farbverlauf mit Logo basierend auf deinem Farbthema';

  @override
  String get placeholderRpgInfo => 'Standardbilder wechseln zwischen normalen und RPG-Varianten, wenn der RPG-Modus aktiviert ist.';

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
  String get settingsRPGModeActive => 'Magischen Text beschwören...';

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
  String get settingsRpgAnimations => 'Seltenheits-Animationen';

  @override
  String get settingsRpgAnimationsSubtitle => 'Leuchteffekte für epische und legendäre Rezepte';

  @override
  String get settingsRpgSounds => 'Soundeffekte';

  @override
  String get settingsRpgSoundsSubtitle => 'Sounds für Erfolge und Level-Ups abspielen';

  @override
  String get settingsRpgAchievements => 'Erfolge';

  @override
  String get settingsRpgAchievementsSubtitle => 'Deine freigeschalteten Erfolge anzeigen';

  @override
  String get settingsRpgStats => 'Koch-Statistiken';

  @override
  String get settingsRpgStatsSubtitle => 'Deine Kochstatistiken anzeigen';

  @override
  String get settingsRpgModeEnabled => 'Verwandle dein Kochen in ein Abenteuer!';

  @override
  String get settingsRecipeLayoutSubtitle => 'Anpassen, wie Rezepte angezeigt werden';

  @override
  String get rarityCommon => 'Gewöhnlich';

  @override
  String get rarityCommonDesc => 'Ein einfaches Alltagsrezept';

  @override
  String get rarityUncommon => 'Ungewöhnlich';

  @override
  String get rarityUncommonDesc => 'Ein leckeres Rezept mit dem gewissen Etwas';

  @override
  String get rarityRare => 'Selten';

  @override
  String get rarityRareDesc => 'Ein besonderes Rezept, das es zu meistern gilt';

  @override
  String get rarityEpic => 'Episch';

  @override
  String get rarityEpicDesc => 'Ein episches Rezept von großer Macht!';

  @override
  String get rarityLegendary => 'Legendär';

  @override
  String get rarityLegendaryDesc => 'Ein legendäres Rezept, würdig der Götter!';

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
  String get rpgMode => 'RPG-Modus';

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
}
