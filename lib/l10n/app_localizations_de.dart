// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get plannerPrevWeek => 'Vorherige Woche';

  @override
  String get convertToSection => 'In Abschnitt umwandeln';

  @override
  String get convertToStep => 'In Schritt umwandeln';

  @override
  String get addSection => 'Abschnitt hinzufügen';

  @override
  String get sectionLabel => 'Abschnitt';

  @override
  String stepsSectionsCount(int steps, int sections) {
    String _temp0 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps Schritte',
      one: '1 Schritt',
    );
    String _temp1 = intl.Intl.pluralLogic(
      sections,
      locale: localeName,
      other: '$sections Abschnitte',
      one: '1 Abschnitt',
    );
    return '$_temp0 · $_temp1';
  }

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
  String get isbnScreenTitle => 'Kochbuch per Barcode hinzufügen';

  @override
  String get isbnAddFromBarcode => 'Kochbuch-Barcode scannen';

  @override
  String get isbnAddFromBarcodeSubtitle => 'Ein gedrucktes Kochbuch über die ISBN hinzufügen';

  @override
  String get isbnCreateBlank => 'Neues Kochbuch erstellen';

  @override
  String get isbnCreateBlankSubtitle => 'Mit einer leeren Sammlung beginnen';

  @override
  String get isbnPointCamera => 'Richte die Kamera auf den Barcode auf der Rückseite';

  @override
  String get isbnTypeLabel => 'ISBN';

  @override
  String get isbnTypeHint => '978-0-00-000000-0';

  @override
  String get isbnTypeHelp => 'Oder gib die ISBN ein, die über dem Barcode steht';

  @override
  String get isbnLookUp => 'Suchen';

  @override
  String get isbnInvalid => 'Das sieht nicht nach einer gültigen ISBN aus. Prüfe die 10 oder 13 Ziffern und versuche es erneut.';

  @override
  String get isbnLookingUp => 'Buch wird gesucht…';

  @override
  String get isbnNotFound => 'Wir konnten dieses Buch in den Katalogen nicht finden. Gib die Details ein, dann fügen wir es trotzdem hinzu.';

  @override
  String get isbnTitleLabel => 'Titel';

  @override
  String get isbnAuthorLabel => 'Autor';

  @override
  String get isbnAddToLibrary => 'Zu meinen Kochbüchern hinzufügen';

  @override
  String get isbnScanAnother => 'Weiteres Buch scannen';

  @override
  String get isbnAlreadyAdded => 'Dieses Buch ist schon in deinen Kochbüchern.';

  @override
  String get isbnOpenCookbook => 'Kochbuch öffnen';

  @override
  String get isbnAddedTitle => 'Zu deinen Kochbüchern hinzugefügt';

  @override
  String get isbnAddedBody => 'Füge jetzt die Rezepte hinzu, die du daraus kochst.';

  @override
  String get isbnAddRecipes => 'Rezepte aus diesem Buch hinzufügen';

  @override
  String isbnPages(int count) {
    return '$count Seiten';
  }

  @override
  String get isbnScanBookDetected => 'Das ist ein Buch-Barcode. Der Kochbuch-Scanner wird geöffnet.';

  @override
  String get isbnCameraUnavailable => 'Kamera nicht verfügbar. Du kannst die ISBN unten trotzdem eingeben.';

  @override
  String get bookScanAction => 'Seiten scannen';

  @override
  String get bookScanFromBook => 'Seiten aus diesem Buch scannen';

  @override
  String get bookScanIntroTitle => 'Seiten aus diesem Buch scannen';

  @override
  String bookScanIntroBody(String book) {
    return 'Fotografiere die Rezeptseiten nacheinander. Sie werden auf diesem Gerät gelesen, und jedes Rezept wird unter $book abgelegt.';
  }

  @override
  String get bookScanTipLightTitle => 'Flache Seite, gutes Licht';

  @override
  String get bookScanTipLightBody => 'Schatten und gewölbte Seiten sind schwerer zu lesen.';

  @override
  String get bookScanTipOrderTitle => 'Eine Seite nach der anderen';

  @override
  String get bookScanTipOrderBody => 'Ein Rezept, das auf der nächsten Seite weitergeht, wird für dich zusammengefügt.';

  @override
  String get bookScanTipPagesTitle => 'Seitenzahlen bleiben erhalten';

  @override
  String get bookScanTipPagesBody => 'Jedes Rezept wird mit der Seite gespeichert, von der es stammt.';

  @override
  String get bookScanStart => 'Scannen starten';

  @override
  String get bookScanChoosePhotos => 'Stattdessen Fotos auswählen';

  @override
  String get bookScanChoosePhotosShort => 'Fotos auswählen';

  @override
  String get bookScanTile => 'Buchseiten';

  @override
  String get bookScanMoreSubtitle => 'Gedruckte Kochbuchseiten in Rezepte verwandeln';

  @override
  String get bookScanPrivacy => 'Die Seiten werden auf diesem Gerät gelesen. Nichts wird hochgeladen.';

  @override
  String get bookScanPrivacySynced => 'Die Seiten werden auf diesem Gerät gelesen. Die Rezepte, die du hinzufügst, werden mit ihren Bildern synchronisiert.';

  @override
  String get bookScanCameraDenied => 'Der Kamerazugriff für Recipe Spellbook ist aus. Schalte ihn in den Einstellungen ein oder wähle Fotos, die du schon gemacht hast.';

  @override
  String get bookScanScannerFailed => 'Der Scanner konnte nicht geöffnet werden. Du kannst trotzdem Fotos auswählen, die du schon gemacht hast.';

  @override
  String bookScanLostPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ein früherer Scan wurde unterbrochen. Seine $count Seiten sind noch auf diesem Gerät.',
      one: 'Ein früherer Scan wurde unterbrochen. Seine Seite ist noch auf diesem Gerät.',
    );
    return '$_temp0';
  }

  @override
  String bookScanReadLostPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Seiten lesen',
      one: '1 Seite lesen',
    );
    return '$_temp0';
  }

  @override
  String get bookScanReadOnly => 'Du kannst dieses Kochbuch nur ansehen, daher können keine Rezepte hinzugefügt werden.';

  @override
  String get bookScanReadingTitle => 'Deine Seiten werden gelesen';

  @override
  String bookScanReadingProgress(int current, int total) {
    return 'Seite $current von $total';
  }

  @override
  String get bookScanFindingRecipes => 'Rezepte werden gesucht';

  @override
  String bookScanFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Rezepte gefunden',
      one: '1 Rezept gefunden',
      zero: 'Keine Rezepte gefunden',
    );
    return '$_temp0';
  }

  @override
  String bookScanPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Seiten',
      one: '1 Seite',
    );
    return '$_temp0';
  }

  @override
  String bookScanPage(String page) {
    return 'S. $page';
  }

  @override
  String bookScanPages(String pages) {
    return 'S. $pages';
  }

  @override
  String bookScanSource(String book, String page) {
    return '$book, S. $page';
  }

  @override
  String bookScanSourcePages(String book, String pages) {
    return '$book, S. $pages';
  }

  @override
  String get bookScanNoPageNumbers => 'Keine Seitenzahlen gefunden';

  @override
  String get bookScanSetPageNumbers => 'Seitenzahlen festlegen';

  @override
  String get bookScanChangePageNumbers => 'Seitenzahlen';

  @override
  String get bookScanPageNumbersTitle => 'Seitenzahlen';

  @override
  String get bookScanFirstPageLabel => 'Erste Seite';

  @override
  String get bookScanFirstPageHelp => 'Die Zahl, die auf der ersten gescannten Seite steht. Die übrigen folgen der Reihe nach.';

  @override
  String bookScanIngredientCount(int count) {
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
  String bookScanStepCount(int count) {
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
  String get bookScanIssueTitle => 'Titel fehlt';

  @override
  String get bookScanIssueIngredients => 'Keine Zutaten gefunden';

  @override
  String get bookScanIssueSteps => 'Keine Schritte gefunden';

  @override
  String get bookScanDuplicate => 'Schon in diesem Buch';

  @override
  String get bookScanUntitled => 'Unbenanntes Rezept';

  @override
  String get bookScanMergeNext => 'Mit dem nächsten zusammenführen';

  @override
  String get bookScanSplit => 'In zwei teilen';

  @override
  String get bookScanDiscarded => 'Rezept verworfen';

  @override
  String get bookScanMerged => 'Rezepte zusammengeführt';

  @override
  String get bookScanSplitHelp => 'Tippe auf die Zeile, mit der das zweite Rezept beginnt.';

  @override
  String get bookScanSplitEditedNote => 'Beide Hälften werden neu von der Seite gelesen, deine Änderungen an diesem Rezept werden also ersetzt.';

  @override
  String get bookScanSplitFailed => 'Mit dieser Zeile kann kein zweites Rezept beginnen.';

  @override
  String bookScanAddAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Rezepte hinzufügen',
      one: '1 Rezept hinzufügen',
    );
    return '$_temp0';
  }

  @override
  String bookScanAdding(int current, int total) {
    return '$current von $total wird hinzugefügt';
  }

  @override
  String bookScanAdded(int count, String book) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Rezepte zu $book hinzugefügt',
      one: '1 Rezept zu $book hinzugefügt',
    );
    return '$_temp0';
  }

  @override
  String bookScanAddFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Rezepte konnten nicht hinzugefügt werden',
      one: '1 Rezept konnte nicht hinzugefügt werden',
    );
    return '$_temp0';
  }

  @override
  String get bookScanChooseCookbookTitle => 'Kochbuch auswählen';

  @override
  String get bookScanChooseCookbook => 'Wähle das Kochbuch, in das die gescannten Rezepte kommen sollen.';

  @override
  String get bookScanNoCookbook => 'Es gibt kein Kochbuch, zu dem Rezepte hinzugefügt werden können.';

  @override
  String bookScanCookbookGoneChoose(String book) {
    return '$book ist nicht mehr auf diesem Gerät. Wähle das Kochbuch, in das diese Rezepte kommen sollen.';
  }

  @override
  String bookScanCookbookGone(String book) {
    return '$book ist nicht mehr auf diesem Gerät, und es gibt kein anderes Kochbuch, zu dem diese Rezepte hinzugefügt werden können.';
  }

  @override
  String get bookScanMore => 'Weitere Seiten scannen';

  @override
  String get bookScanEmptyTitle => 'Keine Rezepte gefunden';

  @override
  String get bookScanEmptyBody => 'Die Seiten wurden gelesen, aber keine sah wie ein Rezept aus. Versuche es noch einmal mit der ganzen Seite im Foto.';

  @override
  String get bookScanNothingReadTitle => 'Nichts konnte gelesen werden';

  @override
  String bookScanNothingReadBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Keine der $count Seiten konnte gelesen werden. Versuche es noch einmal bei gutem Licht, mit der ganzen Seite im Foto.',
      one: 'Die Seite konnte nicht gelesen werden. Versuche es noch einmal bei gutem Licht, mit der ganzen Seite im Foto.',
    );
    return '$_temp0';
  }

  @override
  String get bookScanNothingLeftTitle => 'Nichts mehr hinzuzufügen';

  @override
  String get bookScanNothingLeftBody => 'Jedes gefundene Rezept wurde hinzugefügt oder verworfen. Scanne weitere Seiten oder geh zurück.';

  @override
  String get bookScanTryAgain => 'Erneut scannen';

  @override
  String bookScanUnreadPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Seiten konnten nicht gelesen werden. Scanne sie noch einmal, um das Fehlende hinzuzufügen.',
      one: '1 Seite konnte nicht gelesen werden. Scanne sie noch einmal, um das Fehlende hinzuzufügen.',
    );
    return '$_temp0';
  }

  @override
  String bookScanUnreadPhotos(int count, String photos) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Die Fotos $photos konnten nicht gelesen werden. Scanne diese Seiten noch einmal, um das Fehlende hinzuzufügen.',
      one: 'Foto $photos konnte nicht gelesen werden. Scanne diese Seite noch einmal, um das Fehlende hinzuzufügen.',
    );
    return '$_temp0';
  }

  @override
  String get bookScanDiscardTitle => 'Diesen Scan verwerfen?';

  @override
  String bookScanDiscardBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Die $count gefundenen Rezepte werden nicht hinzugefügt.',
      one: 'Das gefundene Rezept wird nicht hinzugefügt.',
    );
    return '$_temp0';
  }

  @override
  String get bookScanKeepReviewing => 'Weiter prüfen';

  @override
  String get bookScanEditTitle => 'Rezept bearbeiten';

  @override
  String get bookScanFieldPage => 'Seite';

  @override
  String get bookScanFieldSteps => 'Schritte';

  @override
  String get bookScanIngredientsHelp => 'Eine pro Zeile. Beende eine Zeile mit einem Doppelpunkt, um sie zur Überschrift zu machen.';

  @override
  String get bookScanStepsHelp => 'Ein Schritt pro Zeile.';

  @override
  String get bookScanViewPage => 'Seite ansehen';

  @override
  String bookScanPageOf(int current, int total) {
    return 'Seite $current von $total';
  }

  @override
  String get bookScanOptions => 'Weitere Optionen';

  @override
  String get recipeSourceOpen => 'Quelle öffnen';

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
  String get addFirstItem => 'Erstes Element hinzufügen';

  @override
  String get addAMeal => 'Mahlzeit hinzufügen';

  @override
  String get clearFilters => 'Filter zurücksetzen';

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
  String get shoppingSharedLabel => 'Geteilt';

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
  String get importFromFile => 'Aus Datei importieren';

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
  String get tagBudget => 'Günstig';

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
  String get moreLabel => 'Mehr';

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
  String get defaultImagesDescription => 'Standard-App-Grafiken für Rezepte und Kochbücher';

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
  String get settingsKitchenBuddyEnabled => 'Sammle Münzen und kleide deinen Buddy ein!';

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
  String get helpSyncingDesc => 'Mit Premium werden deine Rezepte, Kochbücher und Fotos automatisch auf allen deinen Geräten synchronisiert.';

  @override
  String get helpContactUs => 'Kontakt';

  @override
  String get helpContactUsDesc => 'Hast du Fragen oder Feedback? Schreib uns an support@recipespellbook.app';

  @override
  String get navCommunity => 'Community';

  @override
  String get navMore => 'Mehr';

  @override
  String get navComingSoon => 'Demnächst';

  @override
  String get keyCtrl => 'Strg';

  @override
  String get keyShift => 'Umschalt';

  @override
  String get keyAlt => 'Alt';

  @override
  String get keyEsc => 'Esc';

  @override
  String get keyEnter => 'Enter';

  @override
  String get keyDelete => 'Entf';

  @override
  String get keySpace => 'Leertaste';

  @override
  String get sidebarLibrary => 'Bibliothek';

  @override
  String get sidebarPlan => 'Planen';

  @override
  String get sidebarDiscover => 'Entdecken';

  @override
  String get sidebarAllRecipes => 'Alle Rezepte';

  @override
  String get sidebarCollapse => 'Seitenleiste einklappen';

  @override
  String get sidebarExpand => 'Seitenleiste ausklappen';

  @override
  String get sidebarSwitchCookbook => 'Kochbuch wechseln';

  @override
  String get sidebarManageCookbooks => 'Kochbücher verwalten';

  @override
  String get sidebarSignInToSync => 'Zum Synchronisieren anmelden';

  @override
  String get syncStatusJustNow => 'Gerade synchronisiert';

  @override
  String syncStatusMinutes(int minutes) {
    return 'Vor $minutes Min. synchronisiert';
  }

  @override
  String syncStatusHours(int hours) {
    return 'Vor $hours Std. synchronisiert';
  }

  @override
  String get syncStatusLocal => 'Auf diesem Gerät gespeichert';

  @override
  String get paletteHint => 'Rezepte und Befehle suchen…';

  @override
  String get paletteSectionRecent => 'Zuletzt verwendet';

  @override
  String get paletteSectionGoTo => 'Gehe zu';

  @override
  String get paletteSectionActions => 'Aktionen';

  @override
  String get paletteSectionRecipes => 'Rezepte';

  @override
  String get paletteImportSubtitle => 'Aus einem Link, Foto oder einer Datei';

  @override
  String get paletteAdvancedSearch => 'Mit Filtern suchen';

  @override
  String get paletteToggleTheme => 'Hell / Dunkel umschalten';

  @override
  String get paletteAppearance => 'Erscheinungsbild';

  @override
  String paletteSearchAll(String query) {
    return 'Alle Rezepte nach „$query“ durchsuchen';
  }

  @override
  String get paletteNoMatches => 'Keine Treffer';

  @override
  String get paletteNavigateHint => 'Navigieren';

  @override
  String get paletteOpenHint => 'Öffnen';

  @override
  String get shortcutsTitle => 'Tastenkürzel';

  @override
  String get shortcutsGeneral => 'Allgemein';

  @override
  String get shortcutsNavigation => 'Navigation';

  @override
  String get shortcutsRecipes => 'Rezepte';

  @override
  String get shortcutsShopping => 'Einkaufen';

  @override
  String get shortcutsEditor => 'Editor';

  @override
  String get shortcutCommandPalette => 'Befehlspalette';

  @override
  String get shortcutNewRecipe => 'Neues Rezept';

  @override
  String get shortcutToggleSidebar => 'Seitenleiste ein-/ausblenden';

  @override
  String get shortcutGoBack => 'Zurück';

  @override
  String get shortcutDismiss => 'Schließen';

  @override
  String get shortcutMoveSelection => 'Auswahl verschieben';

  @override
  String get shortcutOpenRecipe => 'Rezept öffnen';

  @override
  String get shortcutAddToSelection => 'Zur Auswahl hinzufügen';

  @override
  String get shortcutRangeSelect => 'Bereich auswählen';

  @override
  String get shortcutClick => 'Klick';

  @override
  String get shortcutTrash => 'In den Papierkorb';

  @override
  String get shortcutAddItem => 'Artikel hinzufügen';

  @override
  String get shortcutToggleItem => 'Artikel abhaken';

  @override
  String get shortcutSaveRecipe => 'Rezept speichern';

  @override
  String get windowMinimize => 'Minimieren';

  @override
  String get windowMaximize => 'Maximieren';

  @override
  String get windowRestore => 'Wiederherstellen';

  @override
  String get windowClose => 'Schließen';

  @override
  String selectionCount(int count) {
    return '$count ausgewählt';
  }

  @override
  String get selectionClear => 'Auswahl aufheben';

  @override
  String get selectAction => 'Auswählen';

  @override
  String get homeGreetingMorning => 'Guten Morgen';

  @override
  String get homeGreetingAfternoon => 'Guten Tag';

  @override
  String get homeGreetingEvening => 'Guten Abend';

  @override
  String get homeNextSevenDays => 'Die nächsten 7 Tage';

  @override
  String get homeOpenList => 'Liste öffnen';

  @override
  String get homeAllCaughtUp => 'Alles erledigt';

  @override
  String homeToBuy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Artikel zu kaufen',
      one: '1 Artikel zu kaufen',
    );
    return '$_temp0';
  }

  @override
  String homeAndMore(int count) {
    return '+$count weitere';
  }

  @override
  String get homeNothingPlanned => 'Nichts geplant';

  @override
  String get homePlanAMeal => 'Mahlzeit planen';

  @override
  String get homeJumpBackIn => 'Weitermachen';

  @override
  String shoppingAddNamed(String name) {
    return '„$name“ hinzufügen';
  }

  @override
  String get shoppingUncheck => 'Zurück auf die Liste';

  @override
  String cookbooksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kochbücher',
      one: '1 Kochbuch',
    );
    return '$_temp0';
  }

  @override
  String get detailChooseRecipe => 'Wähle ein Rezept';

  @override
  String get detailChooseRecipeHint => 'Wähle eins aus der Liste, um es hier zu lesen.';

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
  String get importSelectRecipes => 'Rezepte zum Importieren auswählen';

  @override
  String importRecipesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rezepte',
      one: 'Rezept',
    );
    return '$count $_temp0 gefunden';
  }

  @override
  String importDuplicatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Duplikate',
      one: 'Duplikat',
    );
    return '$count $_temp0';
  }

  @override
  String get importCheckingDuplicates => 'Duplikate werden geprüft...';

  @override
  String importMoreSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'weitere Schritte',
      one: 'weiterer Schritt',
    );
    return '+$count $_temp0';
  }

  @override
  String get importRenameRecipe => 'Rezept umbenennen';

  @override
  String get importNeedsReview => 'Einiges wurde möglicherweise nicht richtig gelesen. Prüfe nach dem Import die Zutaten und Schritte.';

  @override
  String importingCount(int current, int total) {
    return '$current von $total wird importiert...';
  }

  @override
  String get importStopping => 'Wird angehalten...';

  @override
  String importStoppedCount(int imported, int total) {
    return '$imported von $total Rezepten importiert';
  }

  @override
  String importSomeFailed(int imported, int failed) {
    return '$imported importiert, $failed fehlgeschlagen';
  }

  @override
  String importImagesNotSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bilder konnten',
      one: 'Bild konnte',
    );
    return '$count $_temp0 nicht gespeichert werden';
  }

  @override
  String importEntriesLeftOut(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Einträge ohne Zutaten oder Schritte wurden',
      one: 'Eintrag ohne Zutaten oder Schritte wurde',
    );
    return '$count $_temp0 ausgelassen';
  }

  @override
  String get importNothingToImport => 'Kein Rezept gefunden. Es gibt keine Zutaten und keine Schritte zum Importieren.';

  @override
  String get importNoRecipeAtLink => 'Unter diesem Link wurde kein Rezept gefunden.';

  @override
  String get importNoRecipeInText => 'In diesem Text wurde kein Rezept gefunden. Er braucht die Zutaten oder die Schritte.';

  @override
  String get importNoRecipeInFile => 'In dieser Datei wurde kein Rezept gefunden.';

  @override
  String get importFileUnreadable => 'Diese Datei konnte nicht gelesen werden.';

  @override
  String get importPdfMobileOnly => 'PDFs können nur in der mobilen App gelesen werden. Kopiere auf diesem Gerät den Rezepttext und füge ihn als Text ein.';

  @override
  String get importPhotoMobileOnly => 'Fotos können nur in der mobilen App gelesen werden.';

  @override
  String get scanProductNoRecipe => 'Dieses Produkt hat keine Zutaten oder Nährwerte, die als Rezept gespeichert werden könnten.';

  @override
  String get productNotFound => 'Produkt nicht gefunden';

  @override
  String barcodeNotFound(String barcode) {
    return 'Kein Produkt für Barcode gefunden:\n$barcode';
  }

  @override
  String get manualEntryHint => 'Du kannst den Produktnamen manuell eingeben.';

  @override
  String get productLookupFailed => 'Produktsuche fehlgeschlagen';

  @override
  String get productLookupFailedHint => 'Die Produktdatenbank hat nicht geantwortet. Prüfe deine Verbindung und versuche es erneut, oder gib den Produktnamen selbst ein.';

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
  String get allDataDesc => 'Löscht ALLES dauerhaft: lokale Daten, Cloud-Daten und dein Konto. Ein kompletter Neuanfang.';

  @override
  String get allDataWarningTitle => 'Dies löscht alles';

  @override
  String get allDataWarningCloudData => 'Alle Rezepte, Kochbücher und Essenspläne in der Cloud';

  @override
  String get allDataWarningLocalData => 'Alle lokalen Daten auf diesem Gerät';

  @override
  String get allDataWarningAccount => 'Dein Konto (Abo wird bei Anmeldung automatisch wiederhergestellt)';

  @override
  String get allDataWarningSettings => 'Alle App-Einstellungen und Präferenzen';

  @override
  String get allDataIUnderstand => 'Ich verstehe, dass dies alle meine Daten dauerhaft löscht';

  @override
  String get allDataNoUndo => 'Ich verstehe, dass diese Aktion nicht rückgängig gemacht werden kann';

  @override
  String get localNoCloudWarning => 'Du hast kein Cloud Sync, daher gibt es kein Backup zur Wiederherstellung';

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
  String get menuShareMessage => 'Schau dir Recipe Spellbook an, die beste Rezepte-App! https://recipespellbook.app/get';

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
  String get accountTitle => 'Konto';

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
  String get affluentLabsPro => 'Affluent Labs Pro';

  @override
  String cancelledAccessUntil(String date) {
    return 'Gekündigt: Zugang bis $date';
  }

  @override
  String get lifetimeNeverExpires => 'Lebenslang: läuft nie ab';

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
  String aiImportedInto(int count, String cookbook) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Rezepte in $cookbook importiert.',
      one: 'Rezept in $cookbook importiert.',
    );
    return '$_temp0';
  }

  @override
  String get aiNoCookbook => 'Es gibt kein Kochbuch, in das importiert werden kann. Lege zuerst ein Kochbuch an.';

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
  String get payOnceKeepForever => 'Einmal zahlen, für immer behalten';

  @override
  String get cloudSyncFreeTrial => '1 Woche kostenlos testen';

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
    return '$count Rezept(e) in den Papierkorb verschoben';
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
  String get bestValue => 'BESTER WERT';

  @override
  String get save16Badge => 'SPARE 16%';

  @override
  String get monthly => 'Monatlich';

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
  String get featureCloudStorageLimited => 'Cloud-Speicher: begrenzt';

  @override
  String get featureFamilySharing5 => 'Familienfreigabe (5 Mitglieder)';

  @override
  String get featureCloudStorage => 'Cloud-Speicher';

  @override
  String get featureSharedLists => 'Geteilte Einkaufslisten';

  @override
  String get featureSharedCookbooks => 'Geteilte Kochbücher';

  @override
  String get featureSharedMealPlan => 'Geteilte Essensplanung';

  @override
  String get featureAutoBackups => 'Automatische Backups';

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
  String get sectionSchedule => 'Zeitplan';

  @override
  String get sectionMeal => 'Mahlzeit';

  @override
  String get changeTime => 'Uhrzeit ändern';

  @override
  String get replaceMeal => 'Mahlzeit ersetzen';

  @override
  String get cardColor => 'Kartenfarbe';

  @override
  String get mealColorAuto => 'Automatisch';

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
  String plannerMealsRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mahlzeiten entfernt',
      one: '1 Mahlzeit entfernt',
    );
    return '$_temp0';
  }

  @override
  String plannerMealsMoved(String date) {
    return 'Verschoben auf $date';
  }

  @override
  String get plannerChangeMealType => 'Art der Mahlzeit ändern';

  @override
  String get plannerMoveToDate => 'Auf ein anderes Datum verschieben';

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
  String get mealTypeAppetizer => 'Vorspeise';

  @override
  String get allergenContains => 'Enthält';

  @override
  String get settingsIngredientLayout => 'Zutatenlayout';

  @override
  String get ingredientLayoutInline => 'Inline: 1 TL Butter';

  @override
  String get ingredientLayoutColumnar => 'Spalten: Mengen ausgerichtet';

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
  String get transferCodeExpires => 'Dieser Code läuft in 1 Stunde ab';

  @override
  String transferCodeExpiresAt(String time) {
    return 'Dieser Code läuft um $time ab';
  }

  @override
  String transferPhotosLeftOut(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fotos passten nicht in die Übertragung und bleiben auf diesem Gerät.',
      one: '1 Foto passte nicht in die Übertragung und bleibt auf diesem Gerät.',
    );
    return '$_temp0 Um alles mit allen Fotos zu übertragen, nutze diesen Code nicht. Verwende stattdessen „Daten exportieren“ in den Einstellungen auf diesem Gerät und „Daten importieren“ auf dem anderen.';
  }

  @override
  String get transferPhotosLeftOutTitle => 'Nicht alle Fotos passen';

  @override
  String transferPhotosLeftOutAsk(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fotos passen nicht in eine Übertragung und würden auf diesem Gerät bleiben.',
      one: '1 Foto passt nicht in eine Übertragung und würde auf diesem Gerät bleiben.',
    );
    return '$_temp0 Eine Backup-Datei enthält alle Fotos: Brich ab und nutze dann „Daten exportieren“ in den Einstellungen auf diesem Gerät und „Daten importieren“ auf dem anderen. Nutze nur eins von beiden. Ein Backup, das nach einer Übertragung importiert wird, fügt jedes Rezept ein zweites Mal hinzu.';
  }

  @override
  String get transferSendWithoutPhotos => 'Ohne sie senden';

  @override
  String get transferSignInToSend => 'Melde dich an, um deine Rezepte an ein anderes Gerät zu senden. Das empfangende Gerät braucht kein Konto.';

  @override
  String get transferComplete => 'Übertragung abgeschlossen!';

  @override
  String transferAlreadyHere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Rezepte waren schon auf diesem Gerät und wurden unverändert gelassen.',
      one: '1 Rezept war schon auf diesem Gerät und wurde unverändert gelassen.',
    );
    return '$_temp0';
  }

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
  String get transferErrorTooLarge => 'Deine Bibliothek ist zu groß für eine einzige Übertragung. Erstelle mit „Daten exportieren“ in den Einstellungen eine Backup-Datei und nutze „Daten importieren“ auf dem anderen Gerät.';

  @override
  String get transferErrorOffline => 'Der Server ist nicht erreichbar. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get transferErrorServer => 'Der Server konnte die Übertragung nicht abschließen. Versuche es gleich noch einmal.';

  @override
  String get transferErrorCodeNotFound => 'Übertragungscode nicht gefunden. Prüfe den Code und versuche es erneut.';

  @override
  String get transferErrorCodeExpired => 'Dieser Übertragungscode ist abgelaufen. Erstelle auf dem sendenden Gerät einen neuen.';

  @override
  String get transferErrorCodeUsed => 'Dieser Übertragungscode wurde schon verwendet. Falls die Übertragung nicht abgeschlossen wurde, erstelle auf dem sendenden Gerät einen neuen Code. Nichts wird doppelt importiert.';

  @override
  String get transferErrorSyncRunning => 'Gerade läuft eine Synchronisierung. Versuche es gleich noch einmal.';

  @override
  String get transferErrorUnreadable => 'Diese Übertragung konnte nicht gelesen werden. Erstelle auf dem sendenden Gerät einen neuen Code.';

  @override
  String get transferErrorNotSaved => 'Die Übertragung ist angekommen, konnte aber nicht gespeichert werden. Auf diesem Gerät wurde nichts geändert. Versuche es mit demselben Code erneut.';

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
  String get settingsRestoreDefaults => 'Standardrezepte wiederherstellen';

  @override
  String get settingsRestoreDefaultsSubtitle => 'Die 10 Startrezepte erneut hinzufügen';

  @override
  String get settingsRestoreDefaultsConfirm => '10 Startrezepte zu deinem Kochbuch hinzufügen? Vorhandene Rezepte bleiben unverändert.';

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
  String get exportFormattedListSubtitle => 'Mit Kontrollkästchen, ideal für Notiz-Apps';

  @override
  String get exportPlainText => 'Klartext';

  @override
  String get exportPlainTextSubtitle => 'Einfache Liste, überall einfügbar';

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
  String get kitchenBuddyCloset => 'Kleiderschrank';

  @override
  String get kitchenBuddyShop => 'Shop';

  @override
  String get kitchenBuddyAchievements => 'Erfolge';

  @override
  String kitchenBuddyStreakDays(int count) {
    return 'Tagesserie: $count';
  }

  @override
  String get kitchenBuddyClosetEmpty => 'Noch keine Teile! Schau im Shop vorbei, um loszulegen.';

  @override
  String get kitchenBuddyShopOwnEverything => 'Du hast schon alles!';

  @override
  String get kitchenBuddyShopCheckBack => 'Schau wieder vorbei, wenn neue Teile da sind.';

  @override
  String kitchenBuddyConfirmPurchase(String itemName) {
    return '$itemName kaufen?';
  }

  @override
  String kitchenBuddyCostSummary(int price) {
    return 'Das kostet 🪙 $price Spice Coins.';
  }

  @override
  String get kitchenBuddyBuy => 'Kaufen';

  @override
  String kitchenBuddyPurchaseSuccess(String itemName) {
    return '$itemName gekauft!';
  }

  @override
  String get kitchenBuddyNotEnoughCoins => 'Nicht genug Münzen';

  @override
  String kitchenBuddyRequires(String achievementName) {
    return 'Benötigt: $achievementName';
  }

  @override
  String get kitchenBuddyNamingTitle => 'Gib deinem Buddy einen Namen';

  @override
  String get kitchenBuddyIntroTitle => 'Lerne deinen Kitchen Buddy kennen!';

  @override
  String get kitchenBuddyIntroDescription => 'Dieser kleine Koch begleitet dich in der Küche.\nKoche Rezepte und sammle Münzen, um ihn einzukleiden!';

  @override
  String get kitchenBuddyNameLabel => 'Name des Buddys';

  @override
  String get kitchenBuddyNameHint => 'Namen eingeben...';

  @override
  String get kitchenBuddyCreate => 'Buddy erstellen';

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
  String get communityPublishInfo => 'Kochbücher benötigen mindestens 5 Rezepte zum Veröffentlichen. Deine Rezepte werden als Momentaufnahme geteilt, Änderungen werden nicht synchronisiert.';

  @override
  String get communitySelectCookbook => 'Wähle ein Kochbuch zum Veröffentlichen';

  @override
  String communityNeedMinRecipes(int count) {
    return 'Mindestens 5 Rezepte erforderlich (hat $count)';
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
    return '$count Rezepte (benötigt 5+)';
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
    return '\"$title\" heruntergeladen, $count Rezepte hinzugefügt!';
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
  String couldNotOpenUrl(String url) {
    return '$url konnte nicht geöffnet werden';
  }

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
  String get integrationsConnectedManage => 'Verbunden: zum Verwalten tippen';

  @override
  String get integrationsNotConnected => 'Nicht verbunden';

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
  String get onboardingBlankConfirmTitle => 'Ohne Rezepte starten?';

  @override
  String get onboardingBlankConfirmBody => 'Du kannst die Startrezepte später jederzeit in den Einstellungen hinzufügen.';

  @override
  String get onboardingBlankConfirmYes => 'Ja, leer starten';

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
  String get communitySearchHint => 'Rezepte und Kochbücher suchen';

  @override
  String get badgeNewThisWeek => 'Neu diese Woche';

  @override
  String bylineByAuthor(String author) {
    return 'von $author';
  }

  @override
  String countServings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Portionen',
      one: '1 Portion',
    );
    return '$_temp0';
  }

  @override
  String countSaves(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mal gespeichert',
      one: '1 Mal gespeichert',
    );
    return '$_temp0';
  }

  @override
  String countPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fotos',
      one: '1 Foto',
    );
    return '$_temp0';
  }

  @override
  String durationPrep(String duration) {
    return '$duration Vorbereitung';
  }

  @override
  String durationCook(String duration) {
    return '$duration Kochzeit';
  }

  @override
  String get filterHasPhotosOnly => 'Nur mit Fotos';

  @override
  String get filterHasPhotosOnlySub => 'Rezepte ohne Bild ausblenden';

  @override
  String filterApply(int count) {
    return '$count Ergebnisse anzeigen';
  }

  @override
  String get filterNoMatches => 'Keine Treffer';

  @override
  String get previewSavedRecipe => 'Gespeichert';

  @override
  String cookbookDownloadAll(int count) {
    return 'Alle $count Rezepte herunterladen';
  }

  @override
  String get cookbookChooseRecipes => 'Rezepte auswählen';

  @override
  String get cookbookInside => 'IN DIESEM KOCHBUCH';

  @override
  String cookbookSize(String size) {
    return '$size MB';
  }

  @override
  String get publicationStateLive => 'LIVE';

  @override
  String get publicationStatePending => 'IN PRÜFUNG';

  @override
  String publicationUpdatedAgo(String relativeTime) {
    return 'Aktualisiert $relativeTime';
  }

  @override
  String get publicationPushUpdate => 'Update veröffentlichen';

  @override
  String get publicationChanged => 'Geändert';

  @override
  String publicationsChangedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kochbücher wurden seit der Veröffentlichung geändert',
      one: '1 Kochbuch wurde seit der Veröffentlichung geändert',
    );
    return '$_temp0';
  }

  @override
  String get publicationsUpdateAllChanged => 'Alle geänderten aktualisieren';

  @override
  String publicationsUpdateAllConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kochbücher aktualisieren?',
      one: '1 Kochbuch aktualisieren?',
    );
    return '$_temp0';
  }

  @override
  String get publicationsUpdateAllTitle => 'Deine veröffentlichten Kochbücher werden aktualisiert';

  @override
  String publicationsUpdateAllChecking(int current, int total) {
    return 'Suche nach Änderungen ($current/$total)';
  }

  @override
  String publicationsUpdateAllCurrent(int current, int total) {
    return 'Kochbuch $current von $total';
  }

  @override
  String get publicationsUpdateAllStop => 'Anhalten';

  @override
  String get publicationsUpdateAllStopping => 'Wird angehalten...';

  @override
  String get publicationsUpdateAllDone => 'Aktualisierung abgeschlossen';

  @override
  String get publicationsUpdateAllStopped => 'Aktualisierung angehalten';

  @override
  String publicationsUpdateAllUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktualisiert',
      one: '1 aktualisiert',
    );
    return '$_temp0';
  }

  @override
  String publicationsUpdateAllUnchanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bereits aktuell',
      one: '1 bereits aktuell',
    );
    return '$_temp0';
  }

  @override
  String publicationsUpdateAllNoSource(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sind mit keinem Kochbuch auf diesem Gerät verknüpft. Aktualisiere sie einzeln mit Update veröffentlichen.',
      one: '1 ist mit keinem Kochbuch auf diesem Gerät verknüpft. Aktualisiere es einzeln mit Update veröffentlichen.',
    );
    return '$_temp0';
  }

  @override
  String publicationsUpdateAllFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count konnten nicht aktualisiert werden:',
      one: '1 konnte nicht aktualisiert werden:',
    );
    return '$_temp0';
  }

  @override
  String publicationsUpdateAllNotRun(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weitere wurden nicht aktualisiert. Starte Alle geänderten aktualisieren erneut, um den Rest zu erledigen.',
      one: '1 weiteres wurde nicht aktualisiert. Starte Alle geänderten aktualisieren erneut, um den Rest zu erledigen.',
    );
    return '$_temp0';
  }

  @override
  String get publicationsUpdateAllRateLimited => 'Community begrenzt gerade die Uploads. Versuche den Rest später erneut.';

  @override
  String get publicationsUpdateAllNameNotSaved => 'Die Rezepte wurden aktualisiert, aber der neue Name wurde nicht gespeichert.';

  @override
  String get publicationsUpdateAllNothing => 'Es musste nichts aktualisiert werden.';

  @override
  String get publicationNotRated => 'Keine Bewertung';

  @override
  String get publicationStatRecipes => 'Rezepte';

  @override
  String get publicationStatSaves => 'gespeichert';

  @override
  String get publicationStatRating => 'Bewertung';

  @override
  String unpublishConfirmTitle(String name) {
    return '$name zurückziehen?';
  }

  @override
  String get unpublishCancel => 'Veröffentlicht lassen';

  @override
  String get communityKindRecipe => 'Rezept';

  @override
  String get communityKindCookbook => 'Kochbuch';

  @override
  String get preparationTitle => 'Zubereitung';

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
  String get syncPhotosStuck => 'Fotos werden nicht hochgeladen';

  @override
  String get syncPhotosStuckDetail => 'Deine Rezepte sind synchronisiert, aber einige Fotos lassen sich gerade nicht hochladen. Sie werden automatisch erneut versucht.';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Elemente erfolgreich importiert.',
      one: '1 Element erfolgreich importiert.',
      zero: 'Es wurde nichts Neues importiert.',
    );
    return '$_temp0';
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
  String get importGuideQuickTipText => 'Der schnellste Weg? Kopiere einen Rezeptlink und teile ihn mit Recipe Spellbook. Das funktioniert aus fast jeder App.';

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
  String get importGuideInstagramStep4Title => 'Recipe Spellbook finden';

  @override
  String get importGuideInstagramStep4Desc => 'Tippe auf „Mehr“, um alle deine Apps zu sehen, und tippe dann auf Recipe Spellbook.';

  @override
  String get importGuideInstagramStep5Title => 'Vorschau & importieren';

  @override
  String get importGuideInstagramStep5Desc => 'Prüfe die Rezeptdetails und tippe auf Importieren, um es in deinem Kochbuch zu speichern.';

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
  String get importGuideTiktokStep4Title => 'Recipe Spellbook finden';

  @override
  String get importGuideTiktokStep4Desc => 'Tippe auf „Mehr“, um alle deine Apps zu sehen, und tippe dann auf Recipe Spellbook.';

  @override
  String get importGuideTiktokStep5Title => 'Vorschau & importieren';

  @override
  String get importGuideTiktokStep5Desc => 'Prüfe die Rezeptdetails und tippe auf Importieren, um es in deinem Kochbuch zu speichern.';

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
  String get importGuideYoutubeStep3Tip => 'Viele YouTube-Creator schreiben das vollständige Rezept in die Videobeschreibung. Dadurch wird die Extraktion genauer.';

  @override
  String get importGuideYoutubeStep4Title => 'Vorschau & importieren';

  @override
  String get importGuideYoutubeStep4Desc => 'Prüfe das extrahierte Rezept und tippe auf Importieren, um es in deinem Kochbuch zu speichern.';

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
  String get importGuidePinterestStep3Title => 'An Recipe Spellbook teilen';

  @override
  String get importGuidePinterestStep3Desc => 'Tippe auf die Teilen-Schaltfläche und wähle Recipe Spellbook aus der App-Liste.';

  @override
  String get importGuidePinterestStep4Title => 'Vorschau & importieren';

  @override
  String get importGuidePinterestStep4Desc => 'Prüfe die Rezeptdetails und tippe auf Importieren, um es in deinem Kochbuch zu speichern.';

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
  String get importGuideWebsiteStep3Title => 'Tippe auf Teilen';

  @override
  String get importGuideWebsiteStep3Desc => 'Tippe im Browser auf Teilen oder Mehr, um die Teilen-Optionen zu sehen.';

  @override
  String get importGuideWebsiteStep4Title => 'Recipe Spellbook wählen';

  @override
  String get importGuideWebsiteStep4Desc => 'Suche Recipe Spellbook in der App-Liste und tippe darauf.';

  @override
  String get importGuideWebsiteStep5Title => 'Vorschau & importieren';

  @override
  String get importGuideWebsiteStep5Desc => 'Prüfe das extrahierte Rezept und tippe auf Importieren, um es in deinem Kochbuch zu speichern.';

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
  String get importGuidePhotoStep3Title => 'Bild auswählen';

  @override
  String get importGuidePhotoStep3Desc => 'Wähle das Rezeptbild aus deiner Galerie.';

  @override
  String get importGuidePhotoStep4Title => 'Überprüfen & Fehler beheben';

  @override
  String get importGuidePhotoStep4Desc => 'Prüfe das extrahierte Rezept. OCR liest gelegentlich Zeichen falsch: „1/2“ könnte zu „1l2“ werden. Behebe Fehler und speichere.';

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
  String get importGuideTextStep3Tip => 'Funktioniert auch mit unformatiertem Text. Die KI erkennt Zutatenmengen und Arbeitsschritte zuverlässig.';

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
  String get importGuideAiStep2Desc => 'Tippe auf den Prompt-Kopieren-Button. Öffne dann deine bevorzugte AI, ChatGPT, Claude, Gemini oder andere, und füge den Prompt ein.';

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
  String get importGuideOtherAppsStep3Title => 'Datei importieren';

  @override
  String get importGuideOtherAppsStep3Desc => 'Öffne in Recipe Spellbook das Hauptmenü und tippe auf Rezept hinzufügen → Importieren → Datei. Wähle dann die exportierte Datei. Die App verarbeitet JSON, HTML und gängige Rezeptformate.';

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
  String get importGuideDeviceTransferStep2Desc => 'Ein 6-stelliger Code wird generiert. Dieser Code ist 1 Stunde gültig.';

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
  String get faqWhatIsMacroCalcAnswer => 'Der Makro-Rechner schätzt automatisch den Nährstoffgehalt deiner Rezepte, indem jede Zutat mit der USDA-Lebensmitteldatenbank abgeglichen wird. Er berechnet Kalorien, Protein, Kohlenhydrate, Fett, Ballaststoffe, Zucker, Natrium und mehr, alles pro Portion. Du findest ihn im Abschnitt Nährwerte bei jedem Rezept.';

  @override
  String get faqImportFailedTitle => 'Warum ist mein Import fehlgeschlagen?';

  @override
  String get faqImportFailedSubtitle => 'Häufige Ursachen und Lösungen';

  @override
  String get faqImportFailedAnswer => 'Importe können aus mehreren Gründen fehlschlagen:\n\n• Die Website blockiert möglicherweise den automatischen Zugriff. Kopiere stattdessen den Rezepttext und nutze den Textimport.\n• Der Link ist möglicherweise abgelaufen oder privat. Stelle sicher, dass er öffentlich ist.\n• Manche Seiten verwenden schwer lesbare Formate. Versuche stattdessen den KI-Import.\n• Prüfe deine Internetverbindung und versuche es erneut.';

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
  String get communitySortTopRated => 'Am besten bewertet';

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
    return '$count Fotos enthalten';
  }

  @override
  String get communityDownloadTextOnly => 'Nur Text';

  @override
  String get communityDownloadTextOnlySubtitle => 'Nur Rezepte, keine Bilder';

  @override
  String get communityTapToPreview => 'Tippe auf ein Rezept zur Vorschau';

  @override
  String communityImageCountLabel(int count) {
    return '$count Fotos';
  }

  @override
  String get communityYourRating => 'Deine Bewertung';

  @override
  String get communityRateThis => 'Bewerte dies';

  @override
  String communityDownloadingImages(int current, int total) {
    return 'Bilder werden heruntergeladen... ($current/$total)';
  }

  @override
  String get communityViewFullRecipe => 'Vollständiges Rezept anzeigen';

  @override
  String communityMoreIngredients(int count) {
    return '+ $count weitere';
  }

  @override
  String communityStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Schritte',
      one: '1 Schritt',
    );
    return '$_temp0';
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
  String get communityEditDescriptionHint => 'Beschreibung hinzufügen...';

  @override
  String get communityEditTags => 'Tags';

  @override
  String get communityEditSuccess => 'Veröffentlichung aktualisiert';

  @override
  String get communityEditFailed => 'Aktualisierung fehlgeschlagen';

  @override
  String get communityNoRatingsYet => 'Noch keine Bewertungen';

  @override
  String get communityStatusPublished => 'Veröffentlicht';

  @override
  String get communityStatusUnderReview => 'Wird geprüft';

  @override
  String get communityStatusRemoved => 'Entfernt';

  @override
  String get communityUnderReview => 'Dieses Kochbuch wird von unserem Moderationsteam geprüft.';

  @override
  String get communityPublishPreparing => 'Wird vorbereitet...';

  @override
  String communityPublishUploading(int current, int total) {
    return 'Bilder hochladen ($current/$total)...';
  }

  @override
  String get communityPublishPublishing => 'Wird veröffentlicht...';

  @override
  String get communityPublishBackground => 'Du kannst weiterstöbern, während die Veröffentlichung läuft.\nLass die App geöffnet, ein App-Wechsel kann zum Upload-Fehler führen.';

  @override
  String get communityPublishDone => 'Veröffentlicht!';

  @override
  String communityPublishImagesSkipped(int count) {
    return '$count Bilder konnten nicht hochgeladen werden (Upload fehlgeschlagen oder abgelehnt)';
  }

  @override
  String communityPublishRejected(int count) {
    return '$count Bilder konnten nicht hochgeladen werden';
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
  String get communityPublishDescriptionHint => 'Beschreibe dein Kochbuch...';

  @override
  String get communityPublishTags => 'Tags';

  @override
  String get communityPublishIncludeImages => 'Bilder einbeziehen';

  @override
  String get communityPublishIncludeImagesSubtitle => 'Rezeptfotos mit dem Kochbuch hochladen';

  @override
  String get communityPublishSummary => 'Zusammenfassung';

  @override
  String communityPublishRecipesSummary(int count) {
    return '$count Rezepte werden veröffentlicht';
  }

  @override
  String get communityPublishImagesWillUpload => 'Bilder werden hochgeladen';

  @override
  String get communityPublishTextOnlyNoImages => 'Nur Text, keine Bilder';

  @override
  String get communityPublishTryAgain => 'Erneut versuchen';

  @override
  String communityPublishUploadInProgress(int current, int total) {
    return 'Upload läuft ($current/$total). Warte, bis er abgeschlossen ist, bevor du erneut veröffentlichst.';
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
  String get hintRecipeNotes => 'Füge jedem Rezept persönliche Notizen hinzu: Tipps, Änderungen oder Erinnerungen.';

  @override
  String get hintCookbookOrganization => 'Erstelle mehrere Kochbücher, um deine Rezepte nach Thema oder Anlass zu ordnen.';

  @override
  String get hintTagSystem => 'Tagge Rezepte für einfaches Filtern. Erstelle eigene Tags wie \'Schnell\', \'Favorit\' usw.';

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
    return 'Gekündigt: Zugriff bis $date';
  }

  @override
  String get subscriptionRenews => 'Verlängert sich';

  @override
  String get subscriptionPlan => 'Abo';

  @override
  String get subscriptionLifetime => 'Lebenslang: läuft nie ab';

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
  String get scanNoRecipePdf => 'Im PDF wurde kein Rezept gefunden. Prüfe, ob die Seiten die Zutaten oder die Schritte zeigen, oder füge den Text stattdessen ein.';

  @override
  String get scanNoTextImage => 'Kein Text im Bild gefunden. Versuche das Foto bei besserer Beleuchtung aufzunehmen oder nutze stattdessen die Text-Einfügen-Option.';

  @override
  String scanLittleTextImage(int count) {
    return 'Sehr wenig Text erkannt ($count Zeichen). Versuche ein klareres Foto mit besserer Beleuchtung oder nutze stattdessen die Text-Einfügen-Option.';
  }

  @override
  String get scanNoRecipeImage => 'Im Bild wurde kein Rezept gefunden. Prüfe, ob das Foto die Zutaten oder die Schritte zeigt, oder füge den Text stattdessen ein.';

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
  String get communityUnpublishDialogTitle => 'Dieses Kochbuch zurückziehen?';

  @override
  String get communityUnpublishDialogMessage => 'Es wird aus der Community entfernt. Deine Rezepte bleiben unverändert.';

  @override
  String get communityPublishAnotherCookbook => '+ Weiteres Kochbuch veröffentlichen';

  @override
  String get communityShareMoreWithCommunity => 'Teile mehr mit der Community';

  @override
  String get communityUploading => 'Wird hochgeladen...';

  @override
  String get communityStatRecipes => 'Rezepte';

  @override
  String get communityStatDownloads => 'Downloads';

  @override
  String get communityStatRating => 'Bewertung';

  @override
  String get communityRemovedByModerator => 'Dieses Kochbuch wurde von einem Moderator entfernt.';

  @override
  String get communityBrowseRecipes => 'Rezepte';

  @override
  String get communityBrowseCookbooks => 'Kochbücher';

  @override
  String get communityNoRecipesYet => 'Noch keine Community-Rezepte';

  @override
  String get communityTryDifferentSearch => 'Versuche einen anderen Suchbegriff oder lösche deine Filter';

  @override
  String get communityBeFirstToShare => 'Sei der Erste, der ein Kochbuch mit der Community teilt!';

  @override
  String get communityPublishToShare => 'Veröffentliche ein Kochbuch, um deine Rezepte mit allen zu teilen!';

  @override
  String communityFromCookbook(String name) {
    return 'von $name';
  }

  @override
  String communityIngredientsCount(int count) {
    return '$count Zutaten';
  }

  @override
  String communitySaveRecipeTo(String title) {
    return '\"$title\" speichern unter...';
  }

  @override
  String get communityNewCookbook => 'Neues Kochbuch';

  @override
  String get communityExistingCookbook => 'Vorhandenes Kochbuch';

  @override
  String get communityAddToExistingCookbook => 'Zu einem deiner Kochbücher hinzufügen';

  @override
  String get communityChooseCookbook => 'Kochbuch wählen';

  @override
  String get communityNoCookbooksYetSaveNew => 'Noch keine Kochbücher. Rezepte werden in einem neuen Kochbuch gespeichert.';

  @override
  String get communityCreateCookbookFirstToSave => 'Erstelle zuerst ein Kochbuch, um Rezepte zu speichern';

  @override
  String get communitySaveTo => 'Speichern unter:';

  @override
  String communitySaveRecipeCount(int count) {
    return '$count Rezepte speichern';
  }

  @override
  String get communityFailedToSaveRating => 'Bewertung konnte nicht gespeichert werden. Bitte versuche es erneut.';

  @override
  String get communityDownloadingCookbook => 'Kochbuch wird heruntergeladen...';

  @override
  String get communitySavingRecipes => 'Rezepte werden gespeichert...';

  @override
  String communityPartialDownloadSuccess(int count, String title) {
    return '$count Rezepte aus \"$title\" gespeichert';
  }

  @override
  String get communityCannotReportOwn => 'Du kannst deine eigene Veröffentlichung nicht melden';

  @override
  String get communityEditCookbook => 'Kochbuch bearbeiten';

  @override
  String get communityEditTitle => 'Titel';

  @override
  String get communityEditDescriptionLabel => 'Beschreibung';

  @override
  String get communityEditTagsLabel => 'Tags';

  @override
  String get communityCookbookUpdated => 'Kochbuch aktualisiert';

  @override
  String get communityFailedToUpdate => 'Aktualisierung fehlgeschlagen';

  @override
  String get communitySaveChanges => 'Änderungen speichern';

  @override
  String get communityEditTooltip => 'Bearbeiten';

  @override
  String get communitySelectAllRecipes => 'Alle auswählen';

  @override
  String get communityDeselectAllRecipes => 'Alle abwählen';

  @override
  String communitySelectedOfTotal(int selected, int total) {
    return '$selected von $total ausgewählt';
  }

  @override
  String communityDownloadRecipes(int count) {
    return '$count Rezepte herunterladen';
  }

  @override
  String get communityNotCurrentlyRated => 'Noch nicht bewertet';

  @override
  String get communityCannotRateOwnCookbook => 'Du kannst dein eigenes Kochbuch nicht bewerten';

  @override
  String get communitySelectIndividualRecipes => 'Einzelne Rezepte auswählen';

  @override
  String communityWithImages(String size) {
    return '$size mit Bildern';
  }

  @override
  String get communitySaveRecipe => 'Rezept speichern';

  @override
  String get communityNoCookbooksYetCreate => 'Noch keine Kochbücher';

  @override
  String get communityCreateCookbookFirst => 'Erstelle zuerst ein Kochbuch';

  @override
  String get communitySavingRecipe => 'Rezept wird gespeichert...';

  @override
  String communityRecipeSaved(String title) {
    return '\"$title\" gespeichert!';
  }

  @override
  String communityFailedToSave(String error) {
    return 'Speichern fehlgeschlagen: $error';
  }

  @override
  String get communitySaveToMyCookbooks => 'In meinen Kochbüchern speichern';

  @override
  String get communityViewCookbook => 'Kochbuch anzeigen';

  @override
  String get communityPublishInProgress => 'Veröffentlichung läuft, breche zuerst den Upload ab';

  @override
  String get communityUnknownError => 'Unbekannter Fehler';

  @override
  String get communityUploadCancelled => 'Upload abgebrochen';

  @override
  String get communityCancelUpload => 'Upload abbrechen';

  @override
  String get communityCancelling => 'Wird abgebrochen...';

  @override
  String get communityPublishingFailed => 'Veröffentlichung fehlgeschlagen';

  @override
  String communityTagsSummary(int count) {
    return '$count Tags';
  }

  @override
  String get creatorNotFound => 'Ersteller nicht gefunden';

  @override
  String creatorMemberSince(String date) {
    return 'Mitglied seit $date';
  }

  @override
  String get creatorStatRecipes => 'Rezepte';

  @override
  String get creatorStatCookbooks => 'Kochbücher';

  @override
  String get creatorStatDownloads => 'Downloads';

  @override
  String get creatorStatAvgRating => 'Durchschn. Bewertung';

  @override
  String get creatorPublishedCookbooks => 'Veröffentlichte Kochbücher';

  @override
  String get creatorNoCookbooksYet => 'Noch keine veröffentlichten Kochbücher';

  @override
  String creatorRecipesCount(int count) {
    return '$count Rezepte';
  }

  @override
  String get follow => 'Folgen';

  @override
  String get following => 'Folgst du';

  @override
  String get unfollow => 'Entfolgen';

  @override
  String get followers => 'Follower';

  @override
  String get followingLabel => 'Folge ich';

  @override
  String get cannotFollowSelf => 'Du kannst dir nicht selbst folgen';

  @override
  String get paywallUpgradeTitle => 'Recipe Spellbook upgraden';

  @override
  String get paywallSubtitle => 'Deine Rezepte auf jedem Gerät.\nFür immer.';

  @override
  String get paywallPremiumTitle => 'Premium';

  @override
  String get paywallFamilyTitle => 'Familie';

  @override
  String get paywallPremiumFeature1 => 'Cloud-Sync auf allen Geräten';

  @override
  String get paywallPremiumFeature2 => 'Schritt-für-Schritt-Fotos';

  @override
  String get paywallPremiumFeature3 => 'Automatische Backups';

  @override
  String get paywallFamilyFeature1 => 'Alles aus Premium';

  @override
  String get paywallFamilyFeature2 => 'Bis zu 5 Familienmitglieder synchronisieren';

  @override
  String get paywallFamilyFeature3 => 'Geteilte Kochbücher & Einkaufslisten';

  @override
  String paywallGetPlan(String planName, String planPrice) {
    return '$planName holen: $planPrice';
  }

  @override
  String get paywallRestorePurchases => 'Käufe wiederherstellen';

  @override
  String get paywallCompleteYourPurchase => 'Kauf abschließen';

  @override
  String get paywallCompleteMessage => 'Tippe nach dem Kauf unten auf \'Aktualisieren\', um ihn zu aktivieren.';

  @override
  String get paywallRefresh => 'Aktualisieren';

  @override
  String get paywallYoureAllSet => 'Alles erledigt!';

  @override
  String get paywallPurchaseNotDetected => 'Kauf noch nicht erkannt. Versuche es erneut.';

  @override
  String get paywallWebComingSoon => 'Webkäufe bald verfügbar';

  @override
  String get paywallWebMessage => 'Upgrade in der Zwischenzeit auf Android oder iOS. Es synchronisiert sich überall.';

  @override
  String get paywallFreeLabel => 'Kostenlos';

  @override
  String get paywallPremiumLabel => 'Premium';

  @override
  String get paywallFamilyLabel => 'Familie';

  @override
  String get paywallUnlimitedRecipes => 'Unbegrenzte Rezepte';

  @override
  String get paywallCloudSync => 'Cloud-Sync';

  @override
  String get paywallFamilySharing => 'Familienfreigabe';

  @override
  String get adminModerationPanel => 'Moderations-Panel';

  @override
  String get adminPendingReview => 'Ausstehende Prüfung';

  @override
  String get adminPendingFlags => 'Ausstehende Meldungen';

  @override
  String get adminPendingReports => 'Ausstehende Berichte';

  @override
  String get adminUserReports => 'Benutzerberichte';

  @override
  String get adminAllClear => 'Alles erledigt!';

  @override
  String get adminNoPendingItems => 'Keine ausstehenden Elemente zur Überprüfung.';

  @override
  String get adminFailedToApprove => 'Genehmigung fehlgeschlagen';

  @override
  String get adminFailedToRemove => 'Entfernen fehlgeschlagen';

  @override
  String get adminFlagApproved => 'Meldung genehmigt (Veröffentlichung entfernt)';

  @override
  String get adminFailedToApproveFlag => 'Meldung konnte nicht genehmigt werden';

  @override
  String get adminFlagRejected => 'Meldung abgelehnt (Veröffentlichung beibehalten)';

  @override
  String get adminFailedToRejectFlag => 'Meldung konnte nicht abgelehnt werden';

  @override
  String get adminContentRemovedResolved => 'Inhalt entfernt & Bericht gelöst';

  @override
  String get adminReportDismissed => 'Bericht abgewiesen';

  @override
  String get adminFailedToResolveReport => 'Bericht konnte nicht gelöst werden';

  @override
  String adminByPublisher(String name, int count) {
    return 'Von $name · $count Rezepte';
  }

  @override
  String get adminApprove => 'Genehmigen';

  @override
  String get adminRemove => 'Entfernen';

  @override
  String adminReportedBy(String name) {
    return 'Gemeldet von: $name';
  }

  @override
  String adminReason(String reason) {
    return 'Grund: $reason';
  }

  @override
  String get adminRemoveContent => 'Inhalt entfernen';

  @override
  String get adminDismissReport => 'Bericht abweisen';

  @override
  String get adminDismissFlag => 'Meldung abweisen';

  @override
  String get accountProfileUpdated => 'Profil aktualisiert';

  @override
  String get accountProfileUpdateFailed => 'Profil konnte nicht aktualisiert werden';

  @override
  String get accountProfilePictureUpdated => 'Profilbild aktualisiert';

  @override
  String get accountProfilePictureUpdateFailed => 'Profilbild konnte nicht aktualisiert werden';

  @override
  String get accountFailedToUploadImage => 'Bild konnte nicht hochgeladen werden';

  @override
  String get accountDisplayNameHint => 'Anzeigename';

  @override
  String get menuDrawerYourStuff => 'Deine Sachen';

  @override
  String get menuDrawerOrganize => 'Organisiere deine Rezeptsammlungen';

  @override
  String get menuDrawerImportSubtitle => 'Von jeder URL, Foto oder Datei';

  @override
  String get menuDrawerTransferSubtitle => 'Rezepte zwischen Geräten übertragen';

  @override
  String get menuDrawerApp => 'App';

  @override
  String get menuDrawerSettingsSubtitle => 'Design, Sprache & Einstellungen';

  @override
  String get moreAddRecipes => 'Rezepte hinzufügen';

  @override
  String get moreSharing => 'Teilen & Familie';

  @override
  String get moreScanProduct => 'Produkt-Barcode scannen';

  @override
  String get moreScanProductSubtitle => 'Ein verpacktes Produkt nachschlagen';

  @override
  String menuDrawerCouldNotOpenUrl(String url) {
    return '$url konnte nicht geöffnet werden';
  }

  @override
  String menuDrawerCouldNotOpenLink(String error) {
    return 'Link konnte nicht geöffnet werden: $error';
  }

  @override
  String get menuDrawerCouldNotOpenEmail => 'E-Mail-Programm konnte nicht geöffnet werden';

  @override
  String menuDrawerCouldNotOpenEmailError(String error) {
    return 'E-Mail konnte nicht geöffnet werden: $error';
  }

  @override
  String get menuDrawerGuest => 'Gast';

  @override
  String get menuDrawerCommunity => 'COMMUNITY';

  @override
  String get menuDrawerPublishToBuildStats => 'Veröffentliche ein Kochbuch, um hier deine Statistiken aufzubauen';

  @override
  String get menuDrawerRecipesUploaded => 'Rezepte\nhochgeladen';

  @override
  String get menuDrawerDownloads => 'Downloads';

  @override
  String get menuDrawerRating => 'Bewertung';

  @override
  String get recipeListCopyToCookbook => 'In Kochbuch kopieren';

  @override
  String get recipeListMoveToCookbook => 'In Kochbuch verschieben';

  @override
  String recipeListCopyingRecipes(int count) {
    return '$count Rezepte werden kopiert...';
  }

  @override
  String recipeListMovingRecipes(int count) {
    return '$count Rezepte werden verschoben...';
  }

  @override
  String get recipeListCreateAnotherFirst => 'Erstelle zuerst ein weiteres Kochbuch';

  @override
  String get recipeListSortNewest => 'Neueste';

  @override
  String get recipeListSortOldest => 'Älteste';

  @override
  String get recipeListSortRating => 'Bewertung';

  @override
  String get recipeListSortQuickest => 'Schnellste';

  @override
  String get recipeListSizeSmall => 'Klein';

  @override
  String get recipeListSizeMedium => 'Mittel';

  @override
  String get recipeListSizeLarge => 'Groß';

  @override
  String get recipeListPinned => 'Angepinnt';

  @override
  String get recipeListDeselectAll => 'Alle abwählen';

  @override
  String get recipeListSelectAll => 'Alle auswählen';

  @override
  String get plannerPreviousWeek => 'Vorherige Woche';

  @override
  String get plannerNextWeek => 'Nächste Woche';

  @override
  String get plannerMoreOptions => 'Weitere Optionen';

  @override
  String get homeScreenSwitchCookbook => 'Kochbuch wechseln';

  @override
  String get homeScreenNewCookbook => 'Neues Kochbuch';

  @override
  String get shareViewerSharedRecipe => 'Geteiltes Rezept';

  @override
  String get shareViewerGoHome => 'Zur Startseite';

  @override
  String shareViewerSharedBy(String name) {
    return 'Geteilt von $name';
  }

  @override
  String shareViewerExpires(String date) {
    return 'Läuft ab: $date';
  }

  @override
  String get importIssues => 'Import-Probleme';

  @override
  String trashPermanentlyDeleteConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rezepte',
      one: 'Rezept',
    );
    return '$count $_temp0 endgültig löschen? Dies kann nicht rückgängig gemacht werden.';
  }

  @override
  String trashDeletingRecipes(int count) {
    return '$count Rezepte werden gelöscht...';
  }

  @override
  String get trashDeletingAllRecipes => 'Rezepte werden gelöscht...';

  @override
  String cookbooksError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get cookbooksShareFromApp => 'Geteilt aus Recipe Spellbook';

  @override
  String get cookbooksPublishFailed => 'Veröffentlichung fehlgeschlagen';

  @override
  String get displayName => 'Anzeigename';

  @override
  String get editDisplayName => 'Anzeigename bearbeiten';

  @override
  String get displayNameHelper => 'Wird in deinem Profil und in der Community verwendet.';

  @override
  String get saveName => 'Name speichern';

  @override
  String get nameContainsUnsupported => 'Name enthält nicht unterstützte Zeichen';

  @override
  String get nameTooShort => 'Name muss mindestens 2 Zeichen lang sein';

  @override
  String get communitySection => 'COMMUNITY';

  @override
  String get subscriptionSection => 'ABONNEMENT';

  @override
  String get integrationsSection => 'INTEGRATIONEN';

  @override
  String get dangerZoneSection => 'GEFAHRENZONE';

  @override
  String get unlockPremium => 'Premium freischalten';

  @override
  String get oneTimePurchaseDesc => 'Einmalkauf · für immer deins · kein Abo';

  @override
  String get viewPlansPrice => 'Pläne ansehen: 6,99 \$';

  @override
  String get premiumActive => 'Premium: aktiv';

  @override
  String get familyActive => 'Familie: aktiv';

  @override
  String get cloudSyncEnabled => 'Cloud-Sync aktiviert';

  @override
  String get sharedWithMembers => 'Mit bis zu 5 Mitgliedern geteilt';

  @override
  String get yourForever => 'für immer deins';

  @override
  String get publishCookbookToStart => 'Veröffentliche ein Kochbuch, um hier deine Statistiken aufzubauen';

  @override
  String get removePhoto => 'Foto entfernen';

  @override
  String get chooseFromLibrary => 'Aus Bibliothek wählen';

  @override
  String get deleteAccountTitle => 'Dein Konto endgültig löschen?';

  @override
  String get deleteAccountWarning => 'Dies löscht:\n· Alle gespeicherten Rezepte\n· Alle Kochbücher\n· Deine Community-Veröffentlichungen\n· Alle Kontodaten\n\nDies kann nicht rückgängig gemacht werden.';

  @override
  String get typeDeleteToConfirmAccount => 'Gib DELETE ein zur Bestätigung:';

  @override
  String get deleteForever => 'Endgültig löschen';

  @override
  String nameCooldownMessage(String date) {
    return 'Du kannst deinen Namen wieder am $date ändern';
  }

  @override
  String get reportAccount => 'Dieses Konto melden';

  @override
  String get reportAccountTitle => 'Warum meldest du dieses Konto?';

  @override
  String get reportSpam => 'Spam oder Fake-Konto';

  @override
  String get reportInappropriate => 'Unangemessener Inhalt';

  @override
  String get reportStolen => 'Gestohlene Rezepte / Urheberrecht';

  @override
  String get reportHarassment => 'Belästigung';

  @override
  String get reportOther => 'Sonstiges';

  @override
  String get submitReport => 'Meldung senden';

  @override
  String get reportSubmitted => 'Danke für deine Meldung. Wir werden sie in Kürze prüfen.';

  @override
  String get alreadyReportedRecently => 'Du hast dieses Konto bereits kürzlich gemeldet';

  @override
  String get cannotReportSelf => 'Du kannst dich nicht selbst melden';

  @override
  String get pendingAccountReports => 'Kontomeldungen';

  @override
  String get accountReportsResolved => 'Kontomeldung gelöst';

  @override
  String get accountReportDismissed => 'Kontomeldung abgewiesen';

  @override
  String get communityTrending => 'IM TREND';

  @override
  String get communitySearchTags => 'Tags suchen...';

  @override
  String communityNoTagsFound(String query) {
    return 'Keine Tags gefunden für \"$query\"';
  }

  @override
  String get communityConfirm => 'Bestätigen';

  @override
  String get cravingCardTitle => 'Worauf hast du Lust?';

  @override
  String get cravingCardSubtitle => 'Finde Rezepte, die zu deiner Stimmung passen';

  @override
  String get cravingStep1Title => 'Wonach ist dir?';

  @override
  String get cravingStep2Title => 'Etwas genauer?';

  @override
  String get cravingStep3Title => 'Wo sollen wir suchen?';

  @override
  String get cravingResultsTitle => 'Das haben wir gefunden';

  @override
  String get cravingPickOneOrMore => 'Wähle eins oder mehrere';

  @override
  String get cravingMoodHint => 'Wir finden etwas, das du lieben wirst';

  @override
  String cravingCountSelected(int count) {
    return '$count ausgewählt';
  }

  @override
  String get cravingCategoryHint => 'Optional, überspringe es, wenn du für alles offen bist';

  @override
  String get cravingCategoryNarrowHint => 'Grenze ein oder überspringe';

  @override
  String get cravingMoodSweet => 'Süß';

  @override
  String get cravingMoodSavory => 'Herzhaft';

  @override
  String get cravingMoodLight => 'Leicht';

  @override
  String get cravingMoodFilling => 'Sättigend';

  @override
  String get cravingMoodQuick => 'Schnell';

  @override
  String get cravingMoodSpecial => 'Etwas Besonderes';

  @override
  String get cravingCatDessert => 'Dessert';

  @override
  String get cravingCatPastry => 'Gebäck';

  @override
  String get cravingCatBakedGoods => 'Backwaren';

  @override
  String get cravingCatBreakfast => 'Frühstück';

  @override
  String get cravingCatDinner => 'Abendessen';

  @override
  String get cravingCatLunch => 'Mittagessen';

  @override
  String get cravingCatAppetizer => 'Vorspeise';

  @override
  String get cravingCatSoup => 'Suppe';

  @override
  String get cravingCatSauce => 'Soße';

  @override
  String get cravingCatSalad => 'Salat';

  @override
  String get cravingCatSnack => 'Snack';

  @override
  String get cravingCatMainDish => 'Hauptgericht';

  @override
  String get cravingCatPasta => 'Pasta';

  @override
  String get cravingCatRice => 'Reisgerichte';

  @override
  String get cravingCatCasserole => 'Auflauf';

  @override
  String get cravingCatUnder20 => 'Unter 20 Min.';

  @override
  String get cravingCatUnder30 => 'Unter 30 Min.';

  @override
  String get cravingCat5Ings => '5 Zutaten oder weniger';

  @override
  String get cravingCatImpressive => 'Beeindruckend';

  @override
  String get cravingCatCrowdPleaser => 'Publikumsliebling';

  @override
  String get cravingCatFavorites => 'Favoriten';

  @override
  String get cravingSourceMyRecipesTitle => 'Meine gespeicherten Rezepte';

  @override
  String get cravingSourceMyRecipesSubtitle => 'Aus deiner persönlichen Bibliothek';

  @override
  String get cravingSourceCommunityTitle => 'Etwas Neues entdecken';

  @override
  String get cravingSourceCommunitySubtitle => 'Aus der Community';

  @override
  String get cravingSourceBothTitle => 'Beides: überrasch mich';

  @override
  String get cravingSourceBothSubtitle => 'Mischung aus deinen und Community-Rezepten';

  @override
  String get cravingReshuffle => 'Neu mischen';

  @override
  String cravingFoundRecipes(int count) {
    return '$count Rezepte gefunden, die zu deiner Stimmung passen';
  }

  @override
  String get cravingNothingFound => 'Nichts für diese Filter gefunden';

  @override
  String get cravingTryBroader => 'Versuche breitere Optionen oder mische neu';

  @override
  String get cravingAdjustFilters => 'Filter anpassen';

  @override
  String get cravingCookThis => 'Dieses Rezept kochen';

  @override
  String get cravingViewRecipe => 'Rezept ansehen';

  @override
  String get cravingNext => 'Weiter';

  @override
  String get cravingBack => 'Zurück';

  @override
  String get cravingSkipStep => 'Schritt überspringen →';

  @override
  String get cravingFindRecipes => 'Rezepte finden';

  @override
  String get mergeCookbooksMenu => 'Kochbücher zusammenführen';

  @override
  String get mergeCookbooksTitle => 'Kochbücher zusammenführen';

  @override
  String get mergeCookbooksNameLabel => 'Name des neuen Kochbuchs';

  @override
  String get mergeCookbooksDefaultName => 'Zusammengeführtes Kochbuch';

  @override
  String get mergeCookbooksNeedTwo => 'Du brauchst mindestens 2 Kochbücher zum Zusammenführen';

  @override
  String get mergeCookbooksNoRecipes => 'Keine Rezepte zum Zusammenführen';

  @override
  String mergeCookbooksMerging(int count) {
    return '$count Rezepte werden zusammengeführt...';
  }

  @override
  String mergeCookbooksCreated(String name, int count) {
    return '\"$name\" mit $count Rezepten erstellt';
  }

  @override
  String mergeCookbooksFailed(String error) {
    return 'Zusammenführung fehlgeschlagen: $error';
  }

  @override
  String mergeCookbooksButton(int count) {
    return '$count Kochbücher zusammenführen';
  }

  @override
  String get mergeCookbooksCancel => 'Abbrechen';

  @override
  String get combinedIngredients => 'Kombinierte Zutaten';

  @override
  String get communitySubRecipe => 'Unterrezept';

  @override
  String get copyToCookbook => 'In Kochbuch kopieren';

  @override
  String get moveToCookbook => 'In Kochbuch verschieben';

  @override
  String get hintCookbookSwitcher => 'Tippe oben auf den Kochbuchnamen, um zwischen deinen Kochbüchern zu wechseln!';

  @override
  String get paywallPlanPremium => 'Premium';

  @override
  String get paywallPricePremium => '6,99 \$';

  @override
  String get paywallSublinePremium => 'einmalig · für immer deins';

  @override
  String get paywallFeatureCloudSync => 'Cloud-Sync auf allen Geräten';

  @override
  String get paywallFeatureStepPhotos => 'Schritt-für-Schritt-Fotos';

  @override
  String get paywallFeatureAutoBackups => 'Automatische Backups';

  @override
  String get paywallPlanFamily => 'Familie';

  @override
  String get paywallSublineFamily => 'einmalig · mit 5 Personen teilen';

  @override
  String get paywallFeatureEverythingPremium => 'Alles aus Premium';

  @override
  String get paywallFeatureFamilySync => 'Bis zu 5 Familienmitglieder synchronisieren';

  @override
  String get paywallFeatureSharedCookbooks => 'Geteilte Kochbücher & Einkaufslisten';

  @override
  String get paywallPriceAnchor => 'Die meisten Rezept-Apps kosten 5–10 \$/Monat. Das hier nicht.';

  @override
  String get paywallTrustLine => 'Einmal zahlen, für immer deins.';

  @override
  String get paywallPrivacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get paywallTerms => 'AGB';

  @override
  String get paywallPurchaseSuccess => 'Kauf erfolgreich!';

  @override
  String get paywallCheckoutOpened => 'Schließe deinen Kauf im soeben geöffneten Browserfenster ab.';

  @override
  String get paywallWebComingSoonDesc => 'In-App-Käufe für Web kommen bald. Bitte nutze die mobile App zum Abonnieren.';

  @override
  String get paywallCompareFree => 'Kostenlos';

  @override
  String get paywallCompareUnlimitedRecipes => 'Unbegrenzte Rezepte';

  @override
  String get paywallCompareCloudSync => 'Cloud-Sync';

  @override
  String get paywallCompareFamilySharing => 'Familienfreigabe';

  @override
  String linkCurrentlyLinked(int count) {
    return '$count derzeit verknüpft';
  }

  @override
  String get linkSearchRecipes => 'Rezepte suchen...';

  @override
  String linkAvailable(int count) {
    return '$count verfügbar';
  }

  @override
  String linkNoMatch(String query) {
    return 'Kein Treffer für \"$query\"';
  }

  @override
  String get linkNoRecipesAvailable => 'Keine Rezepte verfügbar';

  @override
  String linkFoundInOtherCookbooks(int count) {
    return '$count in anderen Kochbüchern gefunden';
  }

  @override
  String get linkCopyToCookbookNote => 'Rezepte aus anderen Kochbüchern werden beim Verknüpfen in dieses Kochbuch kopiert.';

  @override
  String get linkWillBeCopied => 'Wird in dieses Kochbuch kopiert';

  @override
  String get bulkCopyLabel => 'Kopieren';

  @override
  String get bulkDeleteLabel => 'Löschen';

  @override
  String get bulkMoveLabel => 'Verschieben';

  @override
  String get bulkPinned => 'Angepinnt';

  @override
  String get recipeListCreateCookbookFirst => 'Erstelle zuerst ein weiteres Kochbuch';

  @override
  String recipeListRecipesCopied(int count) {
    return '$count Rezepte kopiert';
  }

  @override
  String recipeListRecipesMoved(int count) {
    return '$count Rezepte verschoben';
  }

  @override
  String selectAllBar(int selectedCount, int totalCount) {
    return '$selectedCount von $totalCount ausgewählt';
  }

  @override
  String get sortAToZ => 'A bis Z';

  @override
  String get sortZToA => 'Z bis A';

  @override
  String get sortNewest => 'Neueste';

  @override
  String get sortOldest => 'Älteste';

  @override
  String get sortRating => 'Bewertung';

  @override
  String get sortQuickest => 'Schnellste';

  @override
  String get sortFavorites => 'Favoriten';

  @override
  String get viewSizeSmall => 'Klein';

  @override
  String get viewSizeMedium => 'Mittel';

  @override
  String get viewSizeLarge => 'Groß';

  @override
  String trashSelectedCount(int count) {
    return '$count ausgewählt';
  }

  @override
  String trashBulkRestored(int count) {
    return '$count Rezepte wiederhergestellt';
  }

  @override
  String trashBulkDeleteConfirm(int count) {
    return '$count Rezepte endgültig löschen? Dies kann nicht rückgängig gemacht werden.';
  }

  @override
  String trashDeletingCount(int count) {
    return '$count Rezepte werden gelöscht...';
  }

  @override
  String trashBulkDeleted(int count) {
    return '$count Rezepte gelöscht';
  }

  @override
  String get shareViewerExpired => 'Dieser Teilen-Link ist abgelaufen';

  @override
  String get shareViewerExpiredLabel => 'Abgelaufen';

  @override
  String get shareViewerFailed => 'Geteilte Rezepte konnten nicht geladen werden';

  @override
  String get shareViewerNoConnection => 'Keine Internetverbindung';

  @override
  String shareViewerHoursRemaining(int hours) {
    return 'Noch $hours Std.';
  }

  @override
  String shareViewerMinutesRemaining(int minutes) {
    return 'Noch $minutes Min.';
  }

  @override
  String shareViewerRecipeCount(int count) {
    return '$count Rezepte';
  }

  @override
  String get shareViewerUntitled => 'Unbenanntes Rezept';

  @override
  String get subRecipeSheetCopyTitle => 'Mit Unterrezepten kopieren?';

  @override
  String get subRecipeSheetMoveTitle => 'Mit Unterrezepten verschieben?';

  @override
  String get subRecipeSheetDeleteTitle => 'Rezept und Unterrezepte löschen?';

  @override
  String get subRecipeSheetPublishTitle => 'Mit Unterrezepten veröffentlichen?';

  @override
  String get subRecipeSheetDownloadTitle => 'Mit Unterrezepten herunterladen?';

  @override
  String subRecipeSheetSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dieses Rezept verknüpft $count Unterrezepte',
      one: 'Dieses Rezept verknüpft 1 Unterrezept',
    );
    return '$_temp0. Entferne das Häkchen bei allem, was du nicht einschließen möchtest.';
  }

  @override
  String subRecipeUsedInOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anderen Rezepten',
      one: '1 anderen Rezept',
    );
    return 'Verwendet in $_temp0';
  }

  @override
  String get subRecipeUsedNowhere => 'In keinem anderen Rezept verwendet';

  @override
  String autoLinkedSubRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Unterrezepte automatisch verknüpft',
      one: '1 Unterrezept automatisch verknüpft',
    );
    return '$_temp0';
  }

  @override
  String get importNearDuplicateExisting => 'Ähnliches vorhanden';

  @override
  String get importNearDuplicateInternal => 'Ähnliches im Stapel';

  @override
  String get backupReminderTitle => 'Cloud-Synchronisierung ist aus';

  @override
  String backupReminderDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Letztes Backup war vor $count Tagen',
      one: 'Letztes Backup war vor 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get backupReminderNever => 'Melde dich an, um deine Rezepte synchron zu halten, oder sichere sie manuell.';

  @override
  String get backupReminderAction => 'Anmelden';

  @override
  String get backupReminderSnooze => 'Später erinnern';

  @override
  String get communityDownloadIncludeSubRecipesTitle => 'Verknüpfte Unterrezepte einschließen?';

  @override
  String communityDownloadIncludeSubRecipesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Die ausgewählten Rezepte verweisen auf $count Unterrezepte. Einschließen, damit die Verknüpfungen nicht brechen?',
      one: 'Die ausgewählten Rezepte verweisen auf 1 Unterrezept. Einschließen, damit die Verknüpfung nicht bricht?',
    );
    return '$_temp0';
  }

  @override
  String get communityDownloadIncludeSubRecipes => 'Unterrezepte einschließen';

  @override
  String get communityDownloadSkipSubRecipes => 'Überspringen';

  @override
  String get actionMove => 'Verschieben';

  @override
  String get communityDownload => 'Herunterladen';

  @override
  String get exportFullZip => 'Vollständiges Backup (ZIP)';

  @override
  String get exportFullZipSubtitle => 'Alle Daten + Bilder in einem portablen Archiv';

  @override
  String get importFromFileSubtitle => 'Unterstützt .json- und .zip-Backup-Dateien';

  @override
  String get importErrorNoPicker => 'Die Dateiauswahl konnte nicht geöffnet werden. Versuche es erneut.';

  @override
  String get importErrorUnreadable => 'Diese Backup-Datei konnte nicht gelesen werden. Sie ist möglicherweise beschädigt oder unvollständig.';

  @override
  String get importErrorNotABackup => 'Diese Datei ist kein Recipe Spellbook-Backup.';

  @override
  String get importErrorMissingData => 'Diese ZIP-Datei ist kein Recipe Spellbook-Backup. Sie enthält keine data.json.';

  @override
  String get importErrorRestoreFailed => 'Dieses Backup konnte nicht wiederhergestellt werden. Es wurde nichts importiert.';

  @override
  String get exportAdvanced => 'Erweiterte Optionen';

  @override
  String get exportCurrentCookbookSubtitle => 'JSON-Datei nur des aktuellen Kochbuchs';

  @override
  String get exportJsonCustom => 'Benutzerdefinierter JSON-Export';

  @override
  String get editAsText => 'Als Text bearbeiten';

  @override
  String get editAsList => 'Als Liste bearbeiten';

  @override
  String get stepsBulkEditHint => 'Trenne jeden Schritt mit einer Leerzeile';

  @override
  String get stepsBulkEditImagesWarning => 'Einige Schrittfotos gehen möglicherweise verloren, wenn du die Anzahl der Schritte änderst.';

  @override
  String get publishToCommunity => 'In der Community veröffentlichen';

  @override
  String get publishSingleRecipeTitle => 'Rezept veröffentlichen';

  @override
  String get publishSingleRecipeBody => 'Teile dieses Rezept im Community-Feed. Aktualisierungen werden nicht synchronisiert, veröffentliche also erneut, um Änderungen zu übertragen.';

  @override
  String get publishSingleRecipeAction => 'Veröffentlichen';

  @override
  String get publishSingleRecipeSuccess => 'Veröffentlicht!';

  @override
  String get creatorsYouFollow => 'Ersteller, denen du folgst';

  @override
  String get noCreatorsYouFollow => 'Folge Erstellern, um hier ihre neuesten Veröffentlichungen zu sehen.';

  @override
  String get shoppingAlsoAddToMealPlan => 'Auch zum Essensplan hinzufügen';

  @override
  String shoppingMealPlanAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Rezepte zum Essensplan hinzugefügt',
      one: '1 Rezept zum Essensplan hinzugefügt',
    );
    return '$_temp0';
  }

  @override
  String shoppingRecipesIngredientsSelected(int recipeCount, int ingredientCount) {
    String _temp0 = intl.Intl.pluralLogic(
      recipeCount,
      locale: localeName,
      other: '$recipeCount Rezepte',
      one: '1 Rezept',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ingredientCount,
      locale: localeName,
      other: '$ingredientCount Zutaten ausgewählt',
      one: '1 Zutat ausgewählt',
    );
    return '$_temp0 • $_temp1';
  }

  @override
  String shoppingItemsFromRecipes(int itemCount, int recipeCount) {
    String _temp0 = intl.Intl.pluralLogic(
      itemCount,
      locale: localeName,
      other: '$itemCount Artikel',
      one: '1 Artikel',
    );
    String _temp1 = intl.Intl.pluralLogic(
      recipeCount,
      locale: localeName,
      other: '$recipeCount Rezepten',
      one: '1 Rezept',
    );
    return '$_temp0 aus $_temp1';
  }

  @override
  String shoppingAddItemsToList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Artikel zur Liste hinzufügen',
      one: '1 Artikel zur Liste hinzufügen',
    );
    return '$_temp0';
  }

  @override
  String get shoppingAddingToList => 'Wird hinzugefügt…';

  @override
  String get shoppingMarkBought => 'Als gekauft markieren';

  @override
  String get shoppingDeleteChecked => 'Abgehakte löschen';

  @override
  String get shareLinkEditDesc => 'Alle mit dem Link können beitreten und diese Liste bearbeiten';

  @override
  String get shareLinkCheckDesc => 'Alle mit dem Link können beitreten und Artikel abhaken';

  @override
  String get shareLinkViewDesc => 'Alle mit dem Link können diese Liste ansehen';

  @override
  String get communityICookedThis => 'Ich habe das gekocht';

  @override
  String get communityICookedThisActive => 'Gekocht';

  @override
  String get communityRepublishRecipes => 'Veröffentlichte Version aktualisieren';

  @override
  String get communityRepublishRecipesBody => 'Ersetzt den veröffentlichten Rezeptinhalt durch deine aktuelle Version. Bewertungen und Downloads bleiben erhalten.';

  @override
  String get communityRepublishRecipesAction => 'Aktualisieren';

  @override
  String get communityRepublishSuccess => 'Veröffentlichte Version aktualisiert';

  @override
  String get shoppingItemRemoved => 'Eintrag entfernt';

  @override
  String shoppingItemsRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge entfernt',
      one: '1 Eintrag entfernt',
    );
    return '$_temp0';
  }

  @override
  String get publicationUnpublished => 'Veröffentlichung zurückgezogen';

  @override
  String get cookModeVoiceTitle => 'Sprachsteuerung';

  @override
  String get cookModeVoiceListening => 'Höre zu… sage \"next\", \"back\", \"pause\" oder \"set timer\"';

  @override
  String get cookModeVoiceUnavailable => 'Sprachsteuerung auf diesem Gerät nicht verfügbar';

  @override
  String get communityRepublishSourceMissing => 'Das Originalrezept konnte auf diesem Gerät nicht gefunden werden. Veröffentliche es erneut aus dem Rezept, um eine aktualisierte Version zu teilen.';

  @override
  String get importNothingSaved => 'Import fehlgeschlagen: Es wurde nichts gespeichert. Bitte versuche es erneut.';

  @override
  String get unsavedChangesBody => 'Du hast ungespeicherte Änderungen. Ohne Speichern verlassen?';

  @override
  String get unsavedKeepEditing => 'Weiter bearbeiten';

  @override
  String get unsavedDiscard => 'Verwerfen';

  @override
  String get ingredientMakeHeader => 'Zur Abschnittsüberschrift machen';

  @override
  String get ingredientMakeIngredient => 'Zur Zutat machen';

  @override
  String get shoppingMoveToList => 'In Liste verschieben';

  @override
  String get shoppingNoOtherLists => 'Keine anderen Listen zum Verschieben';

  @override
  String shoppingMovedToList(String name) {
    return 'Nach $name verschoben';
  }

  @override
  String get exportSaveToDevice => 'Auf Gerät speichern';

  @override
  String get exportSaveToDeviceSubtitle => 'Speichere die Backup-Zip in deinen Dateien oder Downloads';

  @override
  String get exportShareZip => 'Backup teilen';

  @override
  String get exportShareZipSubtitle => 'Sende das Backup an eine andere App oder ein anderes Gerät';

  @override
  String get exportSaved => 'Backup gespeichert';

  @override
  String get exportZipIncludeShopping => 'Einkaufslisten einschließen';

  @override
  String get exportZipIncludeShoppingSubtitle => 'Füge deine Einkaufslisten zum vollständigen Backup hinzu';

  @override
  String get communityPublishCookbookOption => 'Kochbuch veröffentlichen';

  @override
  String get communityPublishCookbookOptionSub => 'Teile ein ganzes Kochbuch (5+ Rezepte)';

  @override
  String get communityPublishSingleRecipeOption => 'Einzelnes Rezept veröffentlichen';

  @override
  String get communityPublishSingleRecipeOptionSub => 'Teile ein Rezept, kein Kochbuch nötig';

  @override
  String get communityPickRecipeToPublish => 'Wähle ein Rezept zum Veröffentlichen';

  @override
  String get communitySearchYourRecipes => 'Durchsuche deine Rezepte…';

  @override
  String get chartCompactDonut => 'Kompakt';

  @override
  String get nutritionPaletteTitle => 'Farbpalette';

  @override
  String get paletteClassic => 'Klassisch';

  @override
  String get paletteWarm => 'Warm';

  @override
  String get paletteCool => 'Kühl';

  @override
  String get paletteMono => 'Mono';

  @override
  String get plannerMonth => 'Monat';

  @override
  String get plannerWeek => 'Woche';

  @override
  String get plannerDay => 'Tag';

  @override
  String get addItem => 'Artikel hinzufügen';

  @override
  String get quickAddHint => 'Artikel hinzufügen…';

  @override
  String get recentlyAdded => 'Gerade hinzugefügt';

  @override
  String get recipeEditIngredientsSteps => 'Zutaten & Anleitung';

  @override
  String get plannerPrevMonth => 'Vorheriger Monat';

  @override
  String get plannerNextMonth => 'Nächster Monat';

  @override
  String get plannerPrevDay => 'Vorheriger Tag';

  @override
  String get plannerNextDay => 'Nächster Tag';

  @override
  String get joinLinkMenuLabel => 'Mit Einladungslink beitreten';

  @override
  String get joinLinkMenuSubtitle => 'Geteilte Liste, Kochbuch oder Familie';

  @override
  String get joinLinkTitle => 'Mit einem Einladungslink beitreten';

  @override
  String get joinLinkTitleList => 'Einer geteilten Liste beitreten';

  @override
  String get joinLinkTitleCookbook => 'Einem geteilten Kochbuch beitreten';

  @override
  String get joinLinkTitleFamily => 'Einer Familie beitreten';

  @override
  String get joinLinkListSubtitle => 'Füge einen Einladungslink ein, den dir jemand geschickt hat';

  @override
  String get joinLinkBody => 'Füge den Einladungslink oder Code ein, den dir jemand geschickt hat. Das funktioniert für geteilte Einkaufslisten, Kochbücher und Familieneinladungen.';

  @override
  String get joinLinkHint => 'Einladungslink oder Code einfügen';

  @override
  String get joinLinkFromClipboard => 'Aus deiner Zwischenablage eingefügt';

  @override
  String get joinLinkInvalid => 'Das sieht nicht nach einem Einladungslink oder Code aus';

  @override
  String get joinLinkOffline => 'Der Code konnte nicht geprüft werden. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get inviteTryAnother => 'Anderen Link versuchen';

  @override
  String get inviteErrorNetwork => 'Keine Verbindung. Prüfe dein Internet und versuche es erneut.';

  @override
  String get inviteErrorSessionExpired => 'Deine Sitzung ist abgelaufen. Melde dich erneut an, um fortzufahren.';

  @override
  String get shareViewerTitleList => 'Geteilte Einkaufsliste';

  @override
  String get shareViewerTitleCookbook => 'Geteiltes Kochbuch';

  @override
  String get shareViewerTitleLink => 'Geteilter Link';

  @override
  String get shareViewerLoadFailed => 'Dieser Link konnte nicht geladen werden';

  @override
  String get shareViewerExpiredHint => 'Bitte die Person, die ihn geteilt hat, um einen neuen Link, oder füge einen anderen ein.';

  @override
  String get shareViewerJoinList => 'Dieser Liste beitreten';

  @override
  String get shareViewerAddToLists => 'Zu meinen Listen hinzufügen';

  @override
  String shareViewerJoinCookbook(String name) {
    return '„$name“ beitreten';
  }

  @override
  String get shareViewerSignInToJoinList => 'Melde dich an, um dieser Einkaufsliste beizutreten. Du wirst hinzugefügt, sobald du angemeldet bist.';

  @override
  String get shareViewerSignInToJoinCookbook => 'Melde dich an, um an diesem Kochbuch mitzuarbeiten. Du wirst hinzugefügt, sobald du angemeldet bist.';

  @override
  String get shareViewerJoinedList => 'Beigetreten! Du findest die Liste unter Einkauf.';

  @override
  String get shareViewerJoinedCookbook => 'Beigetreten! Du findest es bei deinen Kochbüchern.';

  @override
  String get shareViewerOwnItem => 'Das gehört dir. Du hast es schon.';

  @override
  String get shareViewerJoinNeedsSubscription => 'Für die Zusammenarbeit an Kochbüchern brauchst du ein Abo.';

  @override
  String get shareViewerOwnerLapsed => 'Das Abo des Besitzers ist nicht mehr aktiv, daher kann dieses Kochbuch gerade nicht geteilt werden.';

  @override
  String get shareViewerNotCollab => 'Dieser Link ist eine einmalige Kopie, keine Live-Einladung.';

  @override
  String get shareViewerJoinFailed => 'Beitritt fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get familyJoinWithCodeOrLink => 'Mit Code oder Link beitreten';

  @override
  String get familySignInToUse => 'Melde dich an, um eine Familie zu erstellen oder einer beizutreten.';

  @override
  String get familyInviteMember => 'Familienmitglied einladen';

  @override
  String familyInviteSheetTitle(String familyName) {
    return 'Zu $familyName einladen';
  }

  @override
  String get familyInviteSheetBody => 'Lass sie diesen Code mit der Handykamera scannen oder schick ihnen den Link. Sie können den Link oder Code auch unter Familie → Mit Code oder Link beitreten einfügen.';

  @override
  String get familyInviteCode => 'Einladungscode';

  @override
  String get familyInviteLink => 'Einladungslink';

  @override
  String familySeatsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Plätze frei',
      one: '1 Platz frei',
    );
    return '$_temp0';
  }

  @override
  String get familyFullTitle => 'Deine Familie ist voll';

  @override
  String familyFullOwnerBody(int max) {
    return 'Alle $max Plätze sind belegt. Entferne ein Mitglied oder wechsle zu einem größeren Tarif, um jemand Neues einzuladen.';
  }

  @override
  String familyFullMemberBody(int max) {
    return 'Alle $max Plätze sind belegt. Bitte den Besitzer der Familie, Platz zu schaffen.';
  }

  @override
  String get familyAloneHint => 'Bisher ist niemand sonst beigetreten. Lade jemanden ein, um mit dem Teilen zu beginnen.';

  @override
  String get familyYou => 'Du';

  @override
  String get familyErrorSubscription => 'Zum Erstellen einer Familie brauchst du einen Premium-Tarif.';

  @override
  String get familyErrorFull => 'Diese Familie ist voll.';

  @override
  String get familyErrorAlreadyInFamily => 'Du bist schon in einer Familie. Verlasse sie zuerst, um einer anderen beizutreten.';

  @override
  String get familyErrorInvalidCode => 'Dieser Einladungscode ist ungültig. Prüfe ihn oder bitte um einen neuen Link.';

  @override
  String get familyJoinScreenTitle => 'Familieneinladung';

  @override
  String familyJoinPrompt(String familyName) {
    return '$familyName beitreten?';
  }

  @override
  String familyJoinInvitedBy(String name) {
    return '$name hat dich eingeladen, Kochbücher, Einkaufslisten und Essenspläne zu teilen.';
  }

  @override
  String familyJoinGenericPrompt(String code) {
    return 'Der Familie mit dem Einladungscode $code beitreten?';
  }

  @override
  String get familyJoinSignIn => 'Melde dich an, um dieser Familie beizutreten. Du trittst bei, sobald du angemeldet bist.';

  @override
  String get familyJoinConfirm => 'Familie beitreten';

  @override
  String familyJoinAlreadyMember(String familyName) {
    return 'Du bist schon in $familyName.';
  }

  @override
  String familyJoinInOtherFamily(String familyName) {
    return 'Du bist schon in $familyName. Verlasse diese Familie zuerst, um dieser hier beizutreten.';
  }

  @override
  String familyJoinFullBody(String familyName, int max) {
    return '$familyName ist voll ($max von $max Mitgliedern). Bitte den Besitzer, jemanden zu entfernen oder zu einem größeren Tarif zu wechseln.';
  }

  @override
  String get familyJoinOpenFamily => 'Familie öffnen';

  @override
  String get familyJoinInvalid => 'Diese Familieneinladung ist nicht mehr gültig';

  @override
  String get familyJoinInvalidHint => 'Der Einladungscode wurde vielleicht geändert. Bitte um einen neuen Link oder füge einen anderen ein.';

  @override
  String get importLinksNotSaved => 'Verknüpfungen zwischen Rezepten konnten nicht gespeichert werden';

  @override
  String importStoppedSomeFailed(int imported, int total, int failed) {
    return '$imported von $total Rezepten importiert, $failed fehlgeschlagen';
  }

  @override
  String get importDuplicateCheckFailed => 'Duplikate konnten nicht geprüft werden';

  @override
  String scanProductFrom(String brand) {
    return 'Gescanntes Produkt von $brand';
  }

  @override
  String get scanProductNoName => 'Dieses Produkt hat keinen Namen, der zur Einkaufsliste hinzugefügt werden kann.';

  @override
  String communityUsedInRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count Rezepten verwendet',
      one: 'In 1 Rezept verwendet',
    );
    return '$_temp0';
  }

  @override
  String communityPhotosNotDownloaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fotos konnten nicht heruntergeladen werden',
      one: '1 Foto konnte nicht heruntergeladen werden',
    );
    return '$_temp0';
  }

  @override
  String communityRecipesSelected(int selected, int total) {
    return '$selected von $total ausgewählt';
  }

  @override
  String get communityPublishUnderReview => 'Deine Veröffentlichung wird geprüft. Sie ist sichtbar, sobald sie freigegeben wurde.';

  @override
  String communityTagsSelected(int count, int max) {
    return '$count/$max Tags ausgewählt';
  }

  @override
  String communityPublishPhotosRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fotos wurden von der Moderation abgelehnt und fehlen bei:',
      one: '1 Foto wurde von der Moderation abgelehnt und fehlt bei:',
    );
    return '$_temp0';
  }

  @override
  String get communityPublishPhotosFailedTitle => 'Einige Fotos wurden nicht hochgeladen';

  @override
  String get communityPublishPhotosFailedBody => 'Es wurde nichts veröffentlicht. Bei diesen Rezepten konnten Fotos nicht hochgeladen werden:';

  @override
  String get communityRetryFailedPhotos => 'Fehlgeschlagene Fotos erneut hochladen';

  @override
  String communityPublishRateLimitWait(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Upload-Limit erreicht. Weiter in $seconds Sekunden',
      one: 'Upload-Limit erreicht. Weiter in 1 Sekunde',
    );
    return '$_temp0';
  }

  @override
  String get communityPublishServerBusy => 'Ein anderer Upload wird noch verarbeitet. Versuche es in ein paar Minuten erneut.';

  @override
  String get communityPublishDailyLimit => 'Damit würdest du das heutige Limit für Foto-Uploads überschreiten. Versuche es morgen erneut oder veröffentliche ohne Fotos.';

  @override
  String get communityFeedLoadMoreFailed => 'Weitere Einträge konnten nicht geladen werden';

  @override
  String get notifDownloadsOffer => 'Bei Downloads benachrichtigen';

  @override
  String get notifDownloadsOn => 'Du bekommst eine Benachrichtigung, wenn jemand es herunterlädt.';

  @override
  String get notifPermissionDenied => 'Benachrichtigungen für Recipe Spellbook sind aus. Schalte sie in den Geräteeinstellungen ein.';

  @override
  String get syncNotInPlan => 'Cloud-Synchronisierung ist in deinem Tarif nicht enthalten';

  @override
  String transferRowsLeftOut(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge konnten auf diesem Gerät nicht gespeichert werden.',
      one: '1 Eintrag konnte auf diesem Gerät nicht gespeichert werden.',
    );
    return '$_temp0 Gib denselben Code innerhalb eines Tages noch einmal ein, um es erneut zu versuchen.';
  }

  @override
  String backupPhotosLeftOut(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Backup gespeichert, aber $count Fotos fehlen darin.',
      one: 'Backup gespeichert, aber 1 Foto fehlt darin.',
    );
    return '$_temp0 Fotos, die nur in der Cloud liegen, brauchen eine Internetverbindung. Verbinde dich und erstelle das Backup erneut, um sie aufzunehmen.';
  }

  @override
  String get deleteAllDataAccountFailed => 'Dein Konto konnte nicht gelöscht werden, daher wurde nichts gelöscht. Prüfe deine Internetverbindung und versuche es erneut.';

  @override
  String get addRecipeSheetTitle => 'Rezept hinzufügen';

  @override
  String get addRecipeSheetSubtitle => 'Füge einen Link von Instagram, TikTok, einer Website oder sonst woher ein.';

  @override
  String addRecipeSheetPlatformLink(String platform) {
    return '$platform-Link';
  }

  @override
  String get addRecipeSheetLinkHint => 'Rezeptlink einfügen…';

  @override
  String get addRecipeSheetPasteFromClipboard => 'Link aus der Zwischenablage einfügen';

  @override
  String get addRecipeSheetImportFromLink => 'Rezept aus Link importieren';

  @override
  String addRecipeSheetImportFrom(String platform) {
    return 'Von $platform importieren';
  }

  @override
  String get addRecipeSheetImportRecipe => 'Rezept importieren';

  @override
  String get addRecipeSheetOtherWay => 'oder auf anderem Weg';

  @override
  String get addRecipeSheetPhoto => 'Foto';

  @override
  String get addRecipeSheetPasteText => 'Text einfügen';

  @override
  String get addRecipeSheetAi => 'KI';

  @override
  String get addRecipeSheetScan => 'Scannen';

  @override
  String get addRecipeSheetHowToImport => 'So importierst du';

  @override
  String get addRecipeSheetTypeItIn => 'Selbst eintippen';

  @override
  String addRecipeSheetGrabbing(String platform) {
    return 'Rezept wird von $platform geholt…';
  }

  @override
  String get addRecipeNothingToPaste => 'Nichts zum Einfügen. Kopiere zuerst einen Rezeptlink.';

  @override
  String get addRecipePasteLinkFirst => 'Füge zuerst einen Rezeptlink ein.';

  @override
  String get addRecipeNotALink => 'Das sieht nicht nach einem Rezeptlink aus. Füge einen Link ein, der mit https:// beginnt, oder nutze unten „Text einfügen“.';

  @override
  String get addRecipeNoRecipeInJson => 'Aus diesem JSON konnten wir kein Rezept lesen. Nutze für KI-generierte Rezepte unten die Option „KI“.';

  @override
  String get addRecipeInvalidJson => 'Das sieht nach Rezeptdaten aus, ist aber kein gültiges JSON. Kopiere alles und versuche es erneut.';

  @override
  String get addRecipeNoRecipeInText => 'In diesem Text haben wir kein Rezept gefunden. Nutze für lange Rezepte unten „Text einfügen“.';

  @override
  String get addRecipeLinkUnreachable => 'Der Link ist nicht erreichbar. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get addRecipeLinkNeedsLogin => 'Diese Seite erfordert eine Anmeldung, daher können wir sie nicht lesen. Versuche einen öffentlichen Link.';

  @override
  String get addRecipeLinkNotFound => 'Dieser Link wurde nicht gefunden. Prüfe die URL noch einmal.';

  @override
  String get addRecipeLinkUnreadable => 'Aus diesem Link konnten wir kein Rezept lesen. Versuche einen anderen Link oder füge den Rezepttext unten ein.';

  @override
  String addRecipeAddedToShopping(String item) {
    return 'Zur Einkaufsliste hinzugefügt: $item';
  }

  @override
  String addRecipeAddToShoppingFailed(String error) {
    return 'Konnte nicht zur Einkaufsliste hinzugefügt werden: $error';
  }

  @override
  String get paywallHeadline => 'Synchronisiere Rezepte, Kochbücher\nund mehr mit deiner Familie';

  @override
  String get recipeEnhanceWithAi => 'Mit KI verbessern';

  @override
  String featureGateRequiresTier(String tier) {
    return 'Erfordert $tier oder höher';
  }

  @override
  String featureGateUpgradeBody(String tier, String feature) {
    return 'Diese Funktion erfordert $tier oder höher. Upgrade, um $feature und mehr zu nutzen.';
  }

  @override
  String get gatedFeatureCreatorPage => 'Creator-Seite';

  @override
  String get gatedFeatureCustomDomain => 'Eigene Domain';

  @override
  String get storageLimitReachedTitle => 'Speicherlimit erreicht';

  @override
  String storageLimitReachedBody(String used, String limit) {
    return 'Du hast $used MB von deinen $limit belegt. Lösche einige Fotos oder upgrade für mehr Speicher.';
  }

  @override
  String get familySheetPermCanEdit => 'Kann bearbeiten';

  @override
  String get familySheetPermCanEditDesc => 'Rezepte hinzufügen & bearbeiten';

  @override
  String get familySheetPermViewOnly => 'Nur ansehen';

  @override
  String get familySheetPermViewOnlyDesc => 'Kann nichts ändern';

  @override
  String get familySheetPermEditItems => 'Artikel bearbeiten';

  @override
  String get familySheetPermEditItemsDesc => 'Hinzufügen, entfernen & abhaken';

  @override
  String get familySheetPermCheckItems => 'Artikel abhaken';

  @override
  String get familySheetPermCheckItemsDesc => 'Nur Artikel abhaken';

  @override
  String get familySheetCollaborateLive => 'Live zusammenarbeiten';

  @override
  String get familySheetInviteViewCookbook => 'Lade Leute ein, dieses Kochbuch anzusehen';

  @override
  String get familySheetInviteEditCookbook => 'Lade Leute ein, dieses Kochbuch anzusehen oder zu bearbeiten';

  @override
  String get familySheetCookbookNeedsPlan => 'Für die Live-Zusammenarbeit an Kochbüchern brauchst du ein Abo. Einkaufslisten teilen ist kostenlos.';

  @override
  String get familySheetPeopleWithAccess => 'Personen mit Zugriff';

  @override
  String get familySheetInviteWithLink => 'Per Link einladen';

  @override
  String get familySheetCreateInviteLink => 'Einladungslink erstellen';

  @override
  String get familySheetSendCopy => 'Kopie senden';

  @override
  String get familySheetSendCopySubtitle => 'Eine einmalige Momentaufnahme zum Importieren (läuft nach 24 Std. ab)';

  @override
  String get familySheetInviteCopied => 'Einladungslink kopiert. Schick ihn an wen du willst.';

  @override
  String get familySheetAnyoneCanJoin => 'Alle mit diesem Link können beitreten';

  @override
  String get enhanceCopied => 'Kopiert! Füge es in ChatGPT, Claude oder eine andere KI ein.';

  @override
  String get enhanceRecipeUpdated => 'Rezept aktualisiert.';

  @override
  String enhanceUpdateFailed(String error) {
    return 'Das Rezept konnte nicht aktualisiert werden: $error';
  }

  @override
  String get enhanceBackToEdit => 'Zurück zum Bearbeiten';

  @override
  String get enhanceLoadFailed => 'Dieses Rezept konnte nicht geladen werden.';

  @override
  String get enhanceIntroTitle => 'Räume dieses Rezept mit einer KI deiner Wahl auf';

  @override
  String get enhanceIntroBody => 'Sie fügt Abschnittsüberschriften hinzu, schreibt die genauen Mengen in jeden Schritt und bringt die Formatierung in Ordnung, ohne deine Zutaten oder die Zubereitung zu ändern. Deine Fotos, Bewertung und Notizen bleiben erhalten.';

  @override
  String get enhanceStep1Title => 'Kopiere dein Rezept + die Anweisungen';

  @override
  String get enhanceCopyButton => 'Rezept + Prompt kopieren';

  @override
  String get enhanceStep2Title => 'Füge es in ChatGPT, Claude oder eine andere KI ein';

  @override
  String get enhanceStep2Body => 'Die KI gibt aktualisiertes Rezept-JSON zurück. Kopiere dieses JSON.';

  @override
  String get enhanceStep3Title => 'Füge das JSON der KI hier wieder ein';

  @override
  String get enhancePreviewChanges => 'Vorschau der Änderungen';

  @override
  String get enhanceAccept => 'Übernehmen & Rezept aktualisieren';

  @override
  String enhanceSectionsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count Abschnitte',
      one: '+1 Abschnitt',
    );
    return '$_temp0';
  }

  @override
  String enhanceIngredientCount(int before, int after) {
    return 'Zutaten $before → $after';
  }

  @override
  String enhanceStepCount(int before, int after) {
    return 'Schritte $before → $after';
  }

  @override
  String get enhanceCourseAdded => 'Gang hinzugefügt';

  @override
  String get enhanceCategoryAdded => 'Kategorie hinzugefügt';

  @override
  String get enhanceFormattingRefined => 'Formatierung verbessert';

  @override
  String get enhanceWhatChanged => 'Was sich geändert hat';

  @override
  String get enhanceIngredientCountWarning => 'Achtung: Die Anzahl der Zutaten hat sich geändert. Prüfe vor dem Übernehmen, dass nichts verloren gegangen ist.';

  @override
  String get enhanceResult => 'Ergebnis';

  @override
  String get enhanceCompare => 'Vergleichen';

  @override
  String get enhanceAdded => 'Hinzugefügt';

  @override
  String get enhanceRemoved => 'Entfernt';

  @override
  String aiRecipesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Rezepte gefunden',
      one: '1 Rezept gefunden',
    );
    return '$_temp0';
  }

  @override
  String get aiCopyPromptHelp => 'Kopiere diesen Prompt, füge ihn zusammen mit deinem Rezept in eine KI ein (ChatGPT, Claude, Gemini) und füge die Antwort dann unten ein.';

  @override
  String get aiWeirdFormatTip => 'Hast du Rezepte in einem seltsamen Format? Füge sie mit diesem Prompt in eine kostenlose KI ein (ChatGPT, Claude usw.), und sie wandelt sie für dich um. Funktioniert mit Tabellen, E-Mails, Screenshots und mehr!';

  @override
  String get aiPasteResponseTitle => 'KI-Antwort einfügen';

  @override
  String get aiTipsBody => 'Funktioniert mit jeder KI. Du kannst auch ein Rezept fotografieren und das Foto mit dem Prompt einfügen. Wenn das JSON Fehler hat, bitte die KI, sie zu beheben.';

  @override
  String get nutriSheetReviewTitle => 'Nährwerte prüfen';

  @override
  String get nutriSheetReviewHint => 'Tippe unten auf Zutaten, um ihre USDA-Zuordnung zu ändern oder Werte manuell einzugeben.';

  @override
  String nutriSheetManuallyEdited(int count) {
    return '$count manuell bearbeitet';
  }

  @override
  String nutritionCalCount(int count) {
    return '$count kcal';
  }

  @override
  String get nutritionCalUnit => 'kcal';

  @override
  String get nutriSheetTapIngredientHint => 'Tippe auf eine Zutat, um ihre USDA-Zuordnung zu ändern oder Nährwerte manuell einzugeben.';

  @override
  String nutriSheetResultsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ergebnisse gefunden',
      one: '1 Ergebnis gefunden',
    );
    return '$_temp0';
  }

  @override
  String nutriSheetCalPerServing(int count) {
    return '$count kcal pro Portion';
  }

  @override
  String get nutriSheetLinkedRecipe => 'Verknüpftes Rezept';

  @override
  String nutriSheetRecipesLinked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Rezepte verknüpft',
      one: '1 Rezept verknüpft',
    );
    return '$_temp0';
  }

  @override
  String nutriSheetCalTotal(int count) {
    return '$count kcal gesamt';
  }

  @override
  String get nutriSheetNoData => 'Keine Nährwerte';

  @override
  String nutriSheetFromRecipe(String recipe) {
    return 'Nährwerte aus $recipe';
  }

  @override
  String get nutriSheetFromLinkedRecipe => 'Nährwerte aus dem verknüpften Rezept';

  @override
  String get nutriSheetNoDataOpenRecipe => 'Keine Nährwerte. Öffne das Rezept, um sie zuerst zu berechnen.';

  @override
  String get nutriSheetRecipeScale => 'Rezeptmenge';

  @override
  String get nutriSheetRecipeScaleHint => 'Wie viel vom verknüpften Rezept verwendet diese Zutat?';

  @override
  String get nutritionFactsTitle => 'Nährwertangaben';

  @override
  String get recipeEditDetailedNutrition => 'Detaillierte Nährwerte';

  @override
  String get listGenExitBody => 'Möchtest du den Einkaufslisten-Generator wirklich verlassen? Nicht gespeicherte Änderungen gehen verloren.';

  @override
  String get listGenChooseLinked => 'Verknüpfte Rezepte auswählen';

  @override
  String get listGenChooseLinkedBody => 'Einige Zutaten sind mit mehreren Rezepten verknüpft. Wähle aus, welche einbezogen werden sollen.';

  @override
  String get listGenSelectIngredients => 'Zutaten auswählen';

  @override
  String get listGenReviewAdd => 'Prüfen & hinzufügen';

  @override
  String listGenInRecipe(String recipe) {
    return 'in $recipe';
  }

  @override
  String listGenLinksTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Verknüpft mit $count Rezepten. Wähle aus, was einbezogen werden soll:',
      one: 'Verknüpft mit 1 Rezept. Wähle aus, was einbezogen werden soll:',
    );
    return '$_temp0';
  }

  @override
  String listGenSelectedOf(int selected, int total) {
    return '$selected/$total Zutaten';
  }

  @override
  String get listGenLinkedBadge => 'verknüpft';

  @override
  String get listGenPantryBadge => 'Vorrat';

  @override
  String listGenSeeBelow(String title) {
    return 'Siehe „$title“ unten';
  }

  @override
  String get shoppingSharingStopped => 'Teilen beendet';

  @override
  String get shoppingStopSharingOnly => 'Nur Teilen beenden';

  @override
  String get shoppingShopOnInstacart => 'Bei Instacart einkaufen';

  @override
  String shoppingNamedItemRemoved(String name) {
    return '$name entfernt';
  }

  @override
  String get exportLinkedTitle => 'Verknüpfte Rezepte exportieren?';

  @override
  String exportLinkedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dieses Rezept hat $count verknüpfte Rezepte:',
      one: 'Dieses Rezept hat 1 verknüpftes Rezept:',
    );
    return '$_temp0';
  }

  @override
  String get exportLinkedQuestion => 'Möchtest du sie in den Export aufnehmen, damit die Verknüpfungen beim Import erhalten bleiben?';

  @override
  String exportOnlyRecipe(String title) {
    return 'Nur $title';
  }

  @override
  String get exportLinkedAll => 'Alle exportieren';

  @override
  String get pdfLinkedRecipes => 'Verknüpfte Rezepte';

  @override
  String taxonomyCourseExists(String name) {
    return 'Gang „$name“ existiert bereits';
  }

  @override
  String taxonomyCategoryExists(String name) {
    return 'Kategorie „$name“ existiert bereits';
  }

  @override
  String taxonomyCreateError(String error) {
    return 'Fehler beim Erstellen: $error';
  }

  @override
  String get shareViewerLiveCollab => 'Live-Zusammenarbeit';

  @override
  String get shareViewerAddedToLists => 'Zu deinen Listen hinzugefügt';

  @override
  String get cookbookPeopleTitle => 'Personen in diesem Kochbuch';

  @override
  String cravingMoreSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+ $count weitere Schritte',
      one: '+ 1 weiterer Schritt',
    );
    return '$_temp0';
  }

  @override
  String authSignedInAs(String name) {
    return 'Angemeldet als $name';
  }

  @override
  String get authSignedOut => 'Abgemeldet';

  @override
  String get accountStatFollowers => 'Follower';

  @override
  String get accountStatFollowing => 'Folge ich';

  @override
  String get settingsSwitchedToImported => 'Zum importierten Kochbuch gewechselt';

  @override
  String resetFailedNothingDeleted(String error) {
    return 'Zurücksetzen fehlgeschlagen: Es wurden keine Daten gelöscht. ($error)';
  }

  @override
  String selectedOfTotal(int selected, int total) {
    return '$selected von $total';
  }

  @override
  String get platformStripSemantics => 'Funktioniert mit Instagram, TikTok, YouTube, Pinterest und jeder Rezept-Website';

  @override
  String get previewRecipeTitle => 'Omas berühmter Schokoladenkuchen';

  @override
  String get previewRecipeIngredients => '250 g Mehl, 200 g Zucker, 3 Eier';

  @override
  String get previewIngredientFlour => '• 250 g Weizenmehl';

  @override
  String get previewIngredientVanilla => '• 1 TL Vanilleextrakt';

  @override
  String get themePreviewRecipe => 'Butter Chicken';

  @override
  String get themePreviewPrimary => 'Primär';

  @override
  String get themePreviewSecondary => 'Sekundär';

  @override
  String get nutriSheetEditedStatus => 'Manuell bearbeitet';

  @override
  String nutriSheetLinkedNoNutrition(String title) {
    return '$title: keine Nährwertangaben';
  }

  @override
  String get productReportMismatch => 'Stimmt nicht mit dem Etikett überein? Ansehen oder korrigieren';

  @override
  String get clipScreenTitle => 'Rezept aus deinem Browser';

  @override
  String get clipChooseCookbookTitle => 'In welches Kochbuch?';

  @override
  String get clipChooseCookbookMessage => 'Wähle das Kochbuch für das Rezept aus deinem Browser.';

  @override
  String get clipNoCookbook => 'Es gibt kein Kochbuch, in dem das Rezept gespeichert werden kann. Lege eines an und speichere das Rezept dann erneut.';

  @override
  String get webClipperGuideTitle => 'Web-Clipper';

  @override
  String get webClipperGuideSubtitle => 'Rezepte aus Chrome, Edge, Brave oder Firefox mit einem Klick speichern';

  @override
  String get webClipperStep1Title => 'Erweiterung hinzufügen';

  @override
  String get webClipperStep1Desc => 'Installiere den Recipe Spellbook Web Clipper in Chrome, Edge, Brave oder Firefox auf deinem Computer.';

  @override
  String get webClipperStep2Title => 'Rezept öffnen';

  @override
  String get webClipperStep2Desc => 'Öffne in diesem Browser eine beliebige Rezeptseite.';

  @override
  String get webClipperStep3Title => 'Auf Save klicken';

  @override
  String get webClipperStep3Desc => 'Klicke in der Symbolleiste auf die Recipe Spellbook-Schaltfläche und dann auf Save. Oder klicke mit der rechten Maustaste auf die Seite und wähle „Save to Recipe Spellbook“.';

  @override
  String get webClipperStep4Title => 'Prüfen und speichern';

  @override
  String get webClipperStep4Desc => 'Lass den Browser Recipe Spellbook öffnen, wähle ein Kochbuch und speichere das Rezept aus der Vorschau.';

  @override
  String get webClipperTip => 'Funktioniert mit der Recipe Spellbook-App für Windows und Mac. Die Erweiterung liest eine Seite nur, wenn du sie anklickst, und sendet nichts an einen Server.';

  @override
  String get webClipperGetExtension => 'Erweiterung holen';

  @override
  String get videoImportFromDescription => 'Aus der Videobeschreibung';

  @override
  String get videoImportFromCaptions => 'Aus den Untertiteln';

  @override
  String get videoImportCheckText => 'Aus dem Text des Videos gelesen. Prüfe Zutaten und Schritte, bevor du speicherst.';

  @override
  String get videoImportNoRecipeTitle => 'Kein geschriebenes Rezept gefunden';

  @override
  String get videoImportNoRecipeBody => 'Die Videobeschreibung nennt keine Zutaten. Der KI-Import kann den Text des Videos lesen und daraus ein Rezept machen.';

  @override
  String get videoImportUseAi => 'KI-Import verwenden';

  @override
  String get videoImportNoRecipe => 'In der Beschreibung und den Untertiteln dieses Videos wurde kein Rezept gefunden.';

  @override
  String get videoImportUnavailable => 'Dieses Video ist privat, wurde entfernt oder ist nicht verfügbar.';

  @override
  String videoImportRateLimited(String platform) {
    return '$platform begrenzt gerade die Anfragen. Versuche es in ein paar Minuten erneut.';
  }

  @override
  String videoImportOffline(String platform) {
    return '$platform ist nicht erreichbar. Prüfe deine Internetverbindung und versuche es erneut.';
  }

  @override
  String videoImportTimedOut(String platform) {
    return '$platform hat zu lange nicht geantwortet. Versuche es erneut.';
  }

  @override
  String videoImportBlocked(String platform) {
    return '$platform hat der App das Lesen dieses Videos nicht erlaubt. Kopiere die Beschreibung und nutze dann „Text einfügen“.';
  }

  @override
  String get videoImportInstagramBlocked => 'Instagram hat die Bildunterschrift dieses Beitrags nicht freigegeben. Öffne den Beitrag, kopiere die Bildunterschrift und nutze dann „Text einfügen“.';

  @override
  String get videoImportUnreadable => 'Die Seite dieses Videos konnte nicht gelesen werden. Versuche es später erneut oder kopiere die Beschreibung und nutze „Text einfügen“.';

  @override
  String get aiVideoTextIncluded => 'Der Text des Videos wird zusammen mit dem Prompt kopiert. Füge beides in deinen KI-Chat ein und füge die Antwort dann unten ein.';

  @override
  String get plannedServingsHeading => 'Für wie viele Personen';

  @override
  String plannedServingsPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen',
      one: '1 Person',
    );
    return '$_temp0';
  }

  @override
  String get plannedServingsRecipeDefault => 'Portionen laut Rezept';

  @override
  String plannedServingsAsWritten(String servings) {
    return 'Laut Rezept: $servings';
  }

  @override
  String plannedServingsBadge(int count) {
    return 'Für $count';
  }

  @override
  String get plannedServingsSaveUsual => 'Als Standard speichern';

  @override
  String get plannedServingsUsual => 'Unser Standard';

  @override
  String get plannedServingsFewer => 'Weniger Personen';

  @override
  String get plannedServingsMore => 'Mehr Personen';

  @override
  String get settingsHouseholdServings => 'Haushaltsgröße';

  @override
  String get settingsHouseholdServingsUnset => 'Portionen des jeweiligen Rezepts';

  @override
  String get settingsHouseholdServingsHint => 'Neue Mahlzeiten im Planer beginnen mit so vielen Personen, und ihre Einkaufslisten werden passend umgerechnet.';
}
